// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agualector/main.dart';

void main() {
  testWidgets('AguaLector loads and displays Splash Screen', (
    WidgetTester tester,
  ) async {
    // Build our app
    await tester.pumpWidget(const AguaLectorApp());

    // Verify Splash Screen appears initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('v1.3.0'), findsOneWidget);

    // Permitir que los timers y animaciones del Splash se procesen para evitar errores de limpieza
    await tester.pump(const Duration(seconds: 4));
  });
}
