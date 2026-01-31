import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:csv/csv.dart';
import 'database_service.dart';
import '../models/contador.dart';
import '../config/constants.dart';

class CsvImportService {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> importInitialData() async {
    // We remove the early return to ensure all data (including those without coordinates)
    // is loaded correctly on new devices.
    try {
      String csvName = 'LECTURAS_TEN_20260126_1622.csv';
      String csvString;
      try {
        csvString = await rootBundle.loadString('assets/$csvName');
      } catch (e) {
        debugPrint('Archivo Real CSV no encontrado, intentando piloto...');
        csvName = 'LECTURAS_PILOTO.csv';
        try {
          csvString = await rootBundle.loadString('assets/$csvName');
        } catch (_) {
          debugPrint('Ningun CSV encontrado.');
          return;
        }
      }

      // Eliminar BOM si existe
      if (csvString.startsWith('\uFEFF')) {
        csvString = csvString.substring(1);
      }

      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvString,
        eol: '\n',
        fieldDelimiter: ',', // Explicitar delimitador
      );

      if (csvTable.isEmpty) return;

      // Asumimos que la primera fila es encabezado
      final headers = csvTable.first.map((e) => e.toString().trim()).toList();

      // Indices de columnas (con soporte para nuevos encabezados)
      final idxId = headers.indexOf('CODIGO_CONCATENADO');
      final idxNombre = headers.indexOf('NOMBRE_COMPLETO');
      final idxVereda = headers.indexOf('VEREDA');

      // Soporte para encabezados antiguos y nuevos
      int idxLecturaAct = headers.indexOf('LECTURA_ACTUAL');
      if (idxLecturaAct == -1) idxLecturaAct = headers.indexOf('HISTORICO_DIC');

      int idxFecha = headers.indexOf('FECHA_LECTURA');
      if (idxFecha == -1) idxFecha = headers.indexOf('FECHA_HISTORICO_DIC');

      int idxHora = headers.indexOf('HORA_LECTURA');
      if (idxHora == -1) idxHora = headers.indexOf('HORA_HISTORICO_DIC');

      int idxLat = headers.indexOf('LATITUD');
      int idxLng = headers.indexOf('LONGITUD');

      if (idxId == -1 || idxNombre == -1) {
        debugPrint(
          'Error: Columnas requeridas no encontradas en el CSV. Headers: $headers',
        );
        return;
      }

      for (var i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.isEmpty || row.length < headers.length) continue;

        final String id = row[idxId].toString();
        // Skip empty rows
        if (id.isEmpty) continue;

        double? latitud;
        if (idxLat != -1 && row[idxLat] != null) {
          latitud = double.tryParse(row[idxLat].toString());
        }
        double? longitud;
        if (idxLng != -1 && row[idxLng] != null) {
          longitud = double.tryParse(row[idxLng].toString());
        }

        // Check availability
        final existing = await _databaseService.getContadorById(id);

        if (existing != null) {
          // Si ya existe, SOLO actualizamos coordenadas si las tenemos en el CSV
          // Esto preserva el estado actual y lecturas realizadas
          if (latitud != null && longitud != null) {
            await _databaseService.updateContadorUbicacion(
              id,
              latitud,
              longitud,
            );
          }
        } else {
          // Si no existe, creamos uno nuevo
          final String nombre = _toTitleCase(row[idxNombre].toString());
          final String vereda = _toTitleCase(row[idxVereda].toString());

          double? lecturaActual;
          if (idxLecturaAct != -1 &&
              row[idxLecturaAct] != null &&
              row[idxLecturaAct].toString().isNotEmpty) {
            lecturaActual = double.tryParse(row[idxLecturaAct].toString());
          }

          DateTime? fechaLectura;
          if (idxFecha != -1 &&
              row[idxFecha] != null &&
              row[idxFecha].toString().isNotEmpty) {
            String fechaStr = row[idxFecha].toString();
            String horaStr = (idxHora != -1 && row[idxHora] != null)
                ? row[idxHora].toString()
                : '00:00:00';
            try {
              fechaLectura = DateTime.parse('$fechaStr $horaStr');
            } catch (e) {
              fechaLectura = DateTime.now(); // Fallback
            }
          }

          final contador = Contador(
            id: id,
            nombre: nombre,
            vereda: vereda,
            ultimaLectura: lecturaActual,
            fechaUltimaLectura: fechaLectura,
            estado: EstadoContador.pendiente, // Nuevo siempre pendiente
            latitud: latitud,
            longitud: longitud,
          );

          await _databaseService.insertContador(contador);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error importando CSV: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
