import 'package:flutter/material.dart';
import 'dart:async';
import 'package:agualector/screens/lista_contadores_screen.dart';
import 'package:agualector/screens/permission_denied_screen.dart';
import 'package:agualector/config/theme.dart';
import 'package:agualector/services/csv_import_service.dart';
import 'package:agualector/services/permission_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animación (duración visual mínima)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          1.0,
          curve: Curves.easeIn,
        ), // Suavizado completo
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          1.0,
          curve: Curves.easeOutBack,
        ), // Efecto rebote sutil
      ),
    );

    _controller.forward();

    // Iniciar inicialización paralela
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Cronómetro para asegurar tiempo mínimo de splash (3 segundos)
    final stopwatch = Stopwatch()..start();

    // 1. Inicializar base de datos y cargar datos del piloto
    debugPrint('Iniciando importación de datos del piloto...');
    final csvImportService = CsvImportService();
    await csvImportService.importInitialData();
    debugPrint('Importación completada.');

    // 2. Solicitar permisos
    final permissionService = PermissionService();
    final permissionResult = await permissionService.requestAllPermissions();

    debugPrint(
      'Permisos - Cámara: ${permissionResult.cameraGranted}, GPS: ${permissionResult.locationGranted}',
    );

    // 3. Esperar tiempo restante para completar 3 segundos de splash
    final elapsed = stopwatch.elapsedMilliseconds;
    final minSplashDuration = 3000;
    if (elapsed < minSplashDuration) {
      await Future.delayed(Duration(milliseconds: minSplashDuration - elapsed));
    }

    if (mounted) {
      // 4. Navegar según estado de permisos
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => permissionResult.allGranted
              ? const ListaContadoresScreen()
              : PermissionDeniedScreen(permissionResult: permissionResult),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo animado
            FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo_asoguapo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Spacer(),
            // Versión
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
