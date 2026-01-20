import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:csv/csv.dart';
import 'database_service.dart';
import '../models/contador.dart';
import '../models/lectura.dart';
import '../config/constants.dart';

class CsvImportService {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> importInitialData() async {
    // Check if we already have data to avoid duplicate imports
    final existingContadores = await _databaseService.getContadores();
    if (existingContadores.isNotEmpty) {
      return;
    }

    try {
      String csvString = await rootBundle.loadString(
        'assets/LECTURAS_PILOTO.csv',
      );

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

      // Indices de columnas
      final idxId = headers.indexOf('CODIGO_CONCATENADO');
      final idxNombre = headers.indexOf('NOMBRE_COMPLETO');

      final idxVereda = headers.indexOf('VEREDA');

      final idxLecturaAct = headers.indexOf('LECTURA_ACTUAL');
      final idxFecha = headers.indexOf('FECHA_LECTURA');
      final idxHora = headers.indexOf('HORA_LECTURA');

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

        // El requerimiento es: La lectura del CSV (Dec 20) es la "ANTERIOR" para el nuevo periodo.
        // Por lo tanto, el usuario debe aparecer como PENDIENTE para tomar la nueva lectura de Enero.
        EstadoContador estado = EstadoContador.pendiente;

        final contador = Contador(
          id: id,
          nombre: nombre,
          vereda: vereda,
          // La LECTURA_ACTUAL del CSV pasa a ser la ultimaLectura para referencia en la app
          ultimaLectura: lecturaActual,
          fechaUltimaLectura: fechaLectura,
          estado: estado,
        );

        await _databaseService.insertContador(contador);

        // Insertamos la lectura del CSV en el historial para referencia,
        // pero NO afectará el estado (ya que la fecha es vieja, Diciembre 20)
        if (lecturaActual != null &&
            lecturaActual > 0 &&
            fechaLectura != null) {
          final lectura = Lectura(
            contadorId: id,
            nombreUsuario: nombre,
            vereda: vereda,
            lectura: lecturaActual,
            fotoPath: '',
            fecha: fechaLectura,
            sincronizado: true,
          );
          await _databaseService.insertLectura(lectura);
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
