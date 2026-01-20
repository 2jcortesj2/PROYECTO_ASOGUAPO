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

class ExportService {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> exportarLecturas({
    List<Lectura>? lecturasFiltradas,
    String? veredaFiltro,
  }) async {
    try {
      final lecturas =
          lecturasFiltradas ?? await _databaseService.getLecturas();
      if (lecturas.isEmpty) {
        throw Exception('No hay datos para exportar');
      }

      // 1. PREPARAR DATOS CSV Y ZIP
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

      final archive = Archive();

      for (var lectura in lecturas) {
        final contador = contadoresMap[lectura.contadorId];
        final lecturaAnterior = contador?.ultimaLectura ?? 0;
        final consumo = lectura.lectura - lecturaAnterior;

        // Obtener solo el nombre del archivo de la ruta
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

        // Agregar foto al ZIP si existe
        if (lectura.fotoPath.isNotEmpty) {
          final file = File(lectura.fotoPath);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            archive.addFile(ArchiveFile(nombreFoto, bytes.length, bytes));
          }
        }
      }

      // Generar contenido CSV
      String csv = const ListToCsvConverter(
        fieldDelimiter: AppConstants.csvDelimiter,
      ).convert(csvData);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());

      // Determinar código de vereda para el nombre del archivo
      String vCode = 'ALL';
      if (veredaFiltro != null && veredaFiltro != 'Todas') {
        if (veredaFiltro.toUpperCase().contains('RECREO')) {
          vCode = 'REC';
        } else if (veredaFiltro.toUpperCase().contains('PUEBLO')) {
          vCode = 'PUE';
        } else if (veredaFiltro.toUpperCase().contains('TENDIDO')) {
          vCode = 'TEN';
        }
      }

      // Guardar CSV con BOM
      final csvFileName = 'LECTURAS_${vCode}_$timestamp.csv';
      final csvPath = '${directory.path}/$csvFileName';
      final csvFile = File(csvPath);
      await csvFile.writeAsBytes([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);

      // Guardar ZIP
      final zipFileName = 'FOTOS_${vCode}_$timestamp.zip';
      final zipPath = '${directory.path}/$zipFileName';
      final zipData = ZipEncoder().encode(archive);
      final List<XFile> filesToShare = [XFile(csvPath)];

      if (zipData != null) {
        await File(zipPath).writeAsBytes(zipData);
        filesToShare.add(XFile(zipPath));
      }

      // Compartir ambos archivos
      await Share.shareXFiles(
        filesToShare,
        text: 'Reporte de Lecturas y Fotos - Vereda: $vCode',
      );
    } catch (e) {
      rethrow;
    }
  }
}
