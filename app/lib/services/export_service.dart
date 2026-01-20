import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'database_service.dart';
// import '../models/lectura.dart';

class ExportService {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> exportarLecturas() async {
    try {
      final lecturas = await _databaseService.getLecturas();
      if (lecturas.isEmpty) {
        throw Exception('No hay datos para exportar');
      }

      List<List<dynamic>> csvData = [
        [
          'ID_CONTADOR',
          'NOMBRE_USUARIO',
          'VEREDA',
          'LECTURA',
          'FECHA',
          'HORA',
          'LATITUD',
          'LONGITUD',
        ],
      ];

      for (var lectura in lecturas) {
        csvData.add([
          lectura.contadorId,
          lectura.nombreUsuario,
          lectura.vereda,
          lectura.lectura,
          DateFormat('yyyy-MM-dd').format(lectura.fecha),
          DateFormat('HH:mm:ss').format(lectura.fecha),
          lectura.latitud ?? '',
          lectura.longitud ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);

      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/lecturas_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(path)], text: 'Reporte de Lecturas');
    } catch (e) {
      rethrow;
    }
  }
}
