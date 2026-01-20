import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
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
  }) async {
    try {
      final lecturas =
          lecturasFiltradas ?? await _databaseService.getLecturas();

      if (lecturas.isEmpty) {
        throw Exception('No hay datos para exportar');
      }

      // 0. DETERMINAR CÓDIGO DE VEREDA Y TIMESTAMP
      if (veredaFiltro == null || veredaFiltro == 'Todas') {
        throw Exception('Debe seleccionar una vereda específica para exportar');
      }

      String vCode = 'ALL';
      if (veredaFiltro.toUpperCase().contains('RECREO')) {
        vCode = 'REC';
      } else if (veredaFiltro.toUpperCase().contains('PUEBLO')) {
        vCode = 'PUE';
      } else if (veredaFiltro.toUpperCase().contains('TENDIDO')) {
        vCode = 'TEN';
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final List<XFile> filesToShare = [];

      // 1. GENERAR CSV (Si se solicita)
      if (tipo == TipoExportacion.csv || tipo == TipoExportacion.todo) {
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
        final csvPath = '${directory.path}/$csvFileName';
        final csvFile = File(csvPath);
        await csvFile.writeAsString(csv, encoding: utf8);
        filesToShare.add(XFile(csvPath));
      }

      // 2. GENERAR ZIP (Si se solicita)
      if (tipo == TipoExportacion.zip || tipo == TipoExportacion.todo) {
        final archive = Archive();
        bool hasPhotos = false;

        for (var lectura in lecturas) {
          if (lectura.fotoPath.isNotEmpty) {
            final file = File(lectura.fotoPath);
            if (await file.exists()) {
              final String nombreFoto = lectura.fotoPath.split('/').last;
              final bytes = await file.readAsBytes();
              archive.addFile(ArchiveFile(nombreFoto, bytes.length, bytes));
              hasPhotos = true;
            }
          }
        }

        if (hasPhotos) {
          final zipFileName = 'FOTOS_${vCode}_$timestamp.zip';
          final zipPath = '${directory.path}/$zipFileName';
          final zipData = ZipEncoder().encode(archive);

          if (zipData != null) {
            await File(zipPath).writeAsBytes(zipData);
            filesToShare.add(XFile(zipPath));
          }
        } else if (tipo == TipoExportacion.zip) {
          throw Exception('No hay fotos para exportar');
        }
      }

      // 3. COMPARTIR
      if (filesToShare.isNotEmpty) {
        String msgExtra = tipo == TipoExportacion.csv
            ? 'Reporte CSV'
            : tipo == TipoExportacion.zip
            ? 'Fotos ZIP'
            : 'Reporte y Fotos';

        await Share.shareXFiles(
          filesToShare,
          text: '$msgExtra - Vereda: $veredaFiltro ($vCode)',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
