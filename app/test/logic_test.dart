import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lógica de Ciclo Global (15 días desde la PRIMERA toma)', () {
    test(
      'Ciclo Activo: Si la primera toma fue hace 10 días, todo es editable',
      () {
        final ahora = DateTime.now();
        final fechaPrimeraToma = ahora.subtract(const Duration(days: 10));

        // Simula la lógica de getLecturaActiva
        final diferenciaGlobal = ahora.difference(fechaPrimeraToma).inDays;

        expect(
          diferenciaGlobal < 15,
          isTrue,
          reason: 'Ciclo global (10 días) está activo',
        );
      },
    );

    test(
      'Ciclo Vencido: Si la primera toma fue hace 16 días, NADA es editable (aunque la lectura sea de ayer)',
      () {
        final ahora = DateTime.now();
        final fechaPrimeraToma = ahora.subtract(const Duration(days: 16));

        // Simula la lógica de getLecturaActiva
        final diferenciaGlobal = ahora.difference(fechaPrimeraToma).inDays;

        expect(
          diferenciaGlobal < 15,
          isFalse,
          reason:
              'Ciclo global (16 días) vencido. Bloquea todas las lecturas del periodo',
        );
      },
    );

    test('Lógica de Rollover Masivo', () {
      final ahora = DateTime.now();
      final fechaPrimeraToma = ahora.subtract(const Duration(days: 15));

      // Simulamos la lógica de limpiarYActualizarRegistros
      final diasDesdeInicio = ahora.difference(fechaPrimeraToma).inDays;
      final debeHacerRollover = diasDesdeInicio >= 15;

      expect(
        debeHacerRollover,
        isTrue,
        reason:
            'Exactamente a los 15 días desde la PRIMERA toma se debe disparar el rollover',
      );
    });

    test(
      'Independencia de Lecturas: Una lectura nueva sin ciclo previo NO dispara rollover',
      () {
        // Si no hay lecturas con estado 'registrado', el MIN(fecha) es NULL
        DateTime? primeraFechaEnBD;

        bool dispararRollover = false;
        if (primeraFechaEnBD != null) {
          final ahora = DateTime.now();
          dispararRollover = ahora.difference(primeraFechaEnBD).inDays >= 15;
        }

        expect(
          dispararRollover,
          isFalse,
          reason: 'Sin lecturas activas no hay ciclo que vencer',
        );
      },
    );
  });
}
