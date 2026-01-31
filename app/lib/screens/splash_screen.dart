import 'package:flutter/material.dart';
import 'dart:async';
import 'package:agualector/screens/lista_contadores_screen.dart';
import 'package:agualector/screens/permission_denied_screen.dart';
import 'package:agualector/config/theme.dart';
import 'package:agualector/services/csv_import_service.dart';
import 'package:agualector/services/permission_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

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
  late Animation<double>
  _decorationOpacityAnimation; // For shadow and circle background

  @override
  void initState() {
    super.initState();

    // Configurar animación de entrada (logo principal)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Animación para la decoración (sombra y círculo) - Comienza después de un pequeño retraso
    _decorationOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Iniciar inicialización paralela
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Esperar un momento breve para asegurar que el primer frame de Flutter sea idéntico al nativo
    // antes de quitarlo
    await Future.delayed(const Duration(milliseconds: 100));
    FlutterNativeSplash.remove();

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
    const minSplashDuration = 3000;
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
      backgroundColor: const Color(0xFFFFFEFE),
      body: Stack(
        children: [
          // Logo centrado (coincidencia 1:1 con splash nativo Android 12)
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _opacityAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width:
                          108, // Tamaño estándar Android 12 SplashScreen icon
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(
                          _decorationOpacityAnimation.value,
                        ), // Círculo blanco
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(
                              0.2 * _decorationOpacityAnimation.value,
                            ),
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
                );
              },
            ),
          ),

          // Versión y barra de progreso (abajo)
          Positioned(
            bottom: 40.0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _decorationOpacityAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'v1.2.3',
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
    );
  }
}
