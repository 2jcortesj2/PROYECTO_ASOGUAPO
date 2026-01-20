import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'database_service.dart';
import '../models/lectura.dart';
import '../config/constants.dart';

enum TipoExportacion { csv, zip, todo }

class ExportService {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> exportarLecturas({
    List<Lectura>? lecturasFiltradas,
    String? veredaFiltro,
    TipoExportacion tipo = TipoExportacion.todo,
    Function(double)? onProgress,
  }) async {
    try {
      final lecturas =
          lecturasFiltradas ?? await _databaseService.getLecturas();

      if (lecturas.isEmpty) {
        throw Exception('No hay datos para exportar');
      }

      // 0. DETERMINAR CÓDIGO DE VEREDA Y TIMESTAMP
      // if (veredaFiltro == null || veredaFiltro == 'Todas') {
      //   throw Exception('Debe seleccionar una vereda específica para exportar');
      // }

      String vCode = 'ALL';
      final filtro = veredaFiltro ?? 'Todas';

      if (filtro.toUpperCase().contains('RECREO')) {
        vCode = 'REC';
      } else if (filtro.toUpperCase().contains('PUEBLO')) {
        vCode = 'PUE';
      } else if (filtro.toUpperCase().contains('TENDIDO')) {
        vCode = 'TEN';
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final archive = Archive();
      bool hasContent = false;

      // 1. GENERAR CSV (Si se solicita)
      if (tipo == TipoExportacion.csv || tipo == TipoExportacion.todo) {
        if (onProgress != null) onProgress(0.1);

        List<List<dynamic>> csvData = [
          [
            'CODIGO_CONCATENADO',
            'NOMBRE_COMPLETO',
            'VEREDA',
            'LECTURA_ANTERIOR',
            'LECTURA_ACTUAL',
            'CONSUMO',
            'FECHA_LECTURA',
            'HORA_LECTURA',
            'LATITUD',
            'LONGITUD',
            'NOMBRE_FOTO',
          ],
        ];

        final contadores = await _databaseService.getContadores();
        final contadoresMap = {for (var c in contadores) c.id: c};

        for (var lectura in lecturas) {
          final contador = contadoresMap[lectura.contadorId];
          final lecturaAnterior = contador?.ultimaLectura ?? 0;
          final consumo = lectura.lectura - lecturaAnterior;
          final String nombreFoto = lectura.fotoPath.split('/').last;

          csvData.add([
            lectura.contadorId,
            lectura.nombreUsuario,
            lectura.vereda,
            lecturaAnterior.toStringAsFixed(0),
            lectura.lectura.toStringAsFixed(0),
            consumo.toStringAsFixed(0),
            DateFormat('yyyy-MM-dd').format(lectura.fecha),
            DateFormat('HH:mm:ss').format(lectura.fecha),
            lectura.latitud?.toStringAsFixed(6) ?? '',
            lectura.longitud?.toStringAsFixed(6) ?? '',
            nombreFoto,
          ]);
        }

        String csv = const ListToCsvConverter(
          fieldDelimiter: AppConstants.csvDelimiter,
        ).convert(csvData);

        final csvFileName = 'LECTURAS_${vCode}_$timestamp.csv';
        final csvBytes = utf8.encode(csv);
        archive.addFile(ArchiveFile(csvFileName, csvBytes.length, csvBytes));
        hasContent = true;
      }

      // 2. AGREGAR FOTOS AL ARCHIVE (Si se solicita)
      if (tipo == TipoExportacion.zip || tipo == TipoExportacion.todo) {
        int processed = 0;
        final photosWithFile = lecturas
            .where((l) => l.fotoPath.isNotEmpty)
            .toList();
        final totalPhotos = photosWithFile.length;

        for (var lectura in photosWithFile) {
          final file = File(lectura.fotoPath);
          if (await file.exists()) {
            final String nombreFoto = lectura.fotoPath.split('/').last;
            final bytes = await file.readAsBytes();
            archive.addFile(
              ArchiveFile('fotos/$nombreFoto', bytes.length, bytes),
            );
            hasContent = true;
          }
          processed++;
          if (onProgress != null && totalPhotos > 0) {
            // Empezamos en 0.2 y llegamos a 0.8 durante el empaquetado de fotos
            onProgress(0.2 + (processed / totalPhotos * 0.6));
          }
        }
      }

      if (!hasContent) {
        throw Exception('No hay datos o fotos para exportar');
      }

      // 3. COMPRESIÓN Y COMPARTIR (SIEMPRE UN ZIP)
      if (onProgress != null) onProgress(0.9);

      final String suffix = tipo == TipoExportacion.csv
          ? 'REPORTE'
          : (tipo == TipoExportacion.zip ? 'FOTOS' : 'COMPLETO');
      final zipFileName = 'EXPORT_${vCode}_${suffix}_$timestamp.zip';
      final zipPath = p.join(directory.path, zipFileName);

      // Ejecución pesada en Isolate
      final zipData = await compute(_encodeZip, archive);

      if (zipData == null)
        throw Exception('Error al generar el archivo comprimido');

      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipData, flush: true);

      if (onProgress != null) onProgress(1.0);

      await Share.shareXFiles([
        XFile(zipPath, name: zipFileName, mimeType: 'application/zip'),
      ], text: 'Exportación Asoguapo - Vereda: $filtro ($vCode)');
    } catch (e) {
      rethrow;
    }
  }

  /// Función estática requerida para compute (Isolate)
  /// Realiza la codificación ZIP en un hilo separado
  static List<int>? _encodeZip(Archive archive) {
    return ZipEncoder().encode(archive);
  }
}
