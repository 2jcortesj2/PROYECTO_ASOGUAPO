import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'database_service.dart';
import '../models/lectura.dart';

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
          'RUTA_FOTO',
        ],
      ];

      // Obtener contadores para tener la lectura anterior
      final contadores = await _databaseService.getContadores();
      final contadoresMap = {for (var c in contadores) c.id: c};

      for (var lectura in lecturas) {
        final contador = contadoresMap[lectura.contadorId];
        final lecturaAnterior = contador?.ultimaLectura ?? 0;
        final consumo = lectura.lectura - lecturaAnterior;

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
          lectura.fotoPath,
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);

      final directory = await getApplicationDocumentsDirectory();

      // Determinar código de vereda para el nombre del archivo
      String vCode = 'ALL';
      if (veredaFiltro != null && veredaFiltro != 'Todas') {
        if (veredaFiltro.toUpperCase().contains('RECREO'))
          vCode = 'REC';
        else if (veredaFiltro.toUpperCase().contains('PUEBLO'))
          vCode = 'PUE';
        else if (veredaFiltro.toUpperCase().contains('TENDIDO'))
          vCode = 'TEN';
      }

      final fileName =
          'LECTURAS_${vCode}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
      final path = '${directory.path}/$fileName';

      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles([
        XFile(path),
      ], text: 'Reporte de Lecturas $vCode');
    } catch (e) {
      rethrow;
    }
  }
}
