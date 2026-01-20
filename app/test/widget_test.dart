// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agualector/main.dart';
import 'package:agualector/services/permission_service.dart';

void main() {
  testWidgets('AguaLector loads and displays list', (
    WidgetTester tester,
  ) async {
    // Build our app with mocked permission result (all granted)
    final mockResult = PermissionResult(
      cameraGranted: true,
      locationGranted: true,
    );
    await tester.pumpWidget(AguaLectorApp(permissionResult: mockResult));

    // Verify key elements of the main screen
    expect(find.text('Lecturas del Día'), findsOneWidget);
    expect(find.text('Juan Pérez García'), findsOneWidget);

    // Verify FAB functionality
    expect(find.byIcon(Icons.history), findsOneWidget);
  });
}
