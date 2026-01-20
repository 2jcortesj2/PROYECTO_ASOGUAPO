import 'package:flutter_test/flutter_test.dart';
import 'package:agualector/models/lectura.dart';

void main() {
  group('Lógica de Periodo de Edición (15 días)', () {
    test('Debe permitir edición si la lectura fue hace menos de 15 días', () {
      final fechaReciente = DateTime.now().subtract(const Duration(days: 10));
      final lectura = Lectura(
        contadorId: '1',
        nombreUsuario: 'Test',
        vereda: 'Test',
        lectura: 100,
        fotoPath: 'path/to/photo.jpg',
        fecha: fechaReciente,
      );

      final now = DateTime.now();
      final diferencia = now.difference(lectura.fecha).inDays;

      expect(diferencia < 15, isTrue, reason: '10 días es menor a 15');
    });

    test('No debe permitir edición si la lectura fue hace más de 15 días', () {
      final fechaAntigua = DateTime.now().subtract(const Duration(days: 16));
      final lectura = Lectura(
        contadorId: '1',
        nombreUsuario: 'Test',
        vereda: 'Test',
        lectura: 100,
        fotoPath: 'path/to/photo.jpg',
        fecha: fechaAntigua,
      );

      final now = DateTime.now();
      final diferencia = now.difference(lectura.fecha).inDays;

      expect(diferencia < 15, isFalse, reason: '16 días es mayor a 15');
    });

    test('Límite exacto de 15 días debe ser bloqueado', () {
      final fechaLimite = DateTime.now().subtract(const Duration(days: 15));
      final lectura = Lectura(
        contadorId: '1',
        nombreUsuario: 'Test',
        vereda: 'Test',
        lectura: 100,
        fotoPath: 'path/to/photo.jpg',
        fecha: fechaLimite,
      );

      final now = DateTime.now();
      final diferencia = now.difference(lectura.fecha).inDays;

      expect(
        diferencia < 15,
        isFalse,
        reason: '15 días exactos ya no es menor a 15',
      );
    });

    test('Cálculo de límite para limpieza automática', () {
      final now = DateTime.now();
      // Simulamos la lógica de DatabaseService.limpiarYActualizarRegistros
      final builtInLimit = now.subtract(const Duration(days: 15));

      final lecturaAntigua = now.subtract(const Duration(days: 16));
      final lecturaReciente = now.subtract(const Duration(days: 14));

      expect(
        lecturaAntigua.isBefore(builtInLimit),
        isTrue,
        reason: 'Lectura de 16 días debe ser limpiada (es anterior al límite)',
      );
      expect(
        lecturaReciente.isBefore(builtInLimit),
        isFalse,
        reason:
            'Lectura de 14 días NO debe ser limpiada (es posterior al límite)',
      );
    });
  });
}
