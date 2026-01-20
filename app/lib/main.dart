import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/theme.dart';
import 'screens/lista_contadores_screen.dart';
import 'services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación solo vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar estilo de barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Solicitar todos los permisos al inicio de la aplicación
  final permissionService = PermissionService();
  final permissionResult = await permissionService.requestAllPermissions();

  // Log del resultado de permisos (útil para debugging)
  debugPrint(
    'Permisos - Cámara: ${permissionResult.cameraGranted}, GPS: ${permissionResult.locationGranted}',
  );

  runApp(AguaLectorApp(permissionResult: permissionResult));
}

/// Aplicación principal AguaLector
class AguaLectorApp extends StatelessWidget {
  final PermissionResult permissionResult;

  const AguaLectorApp({super.key, required this.permissionResult});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AguaLector',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: permissionResult.allGranted
          ? const ListaContadoresScreen()
          : PermissionDeniedScreen(permissionResult: permissionResult),
    );
  }
}

/// Pantalla mostrada cuando faltan permisos críticos
class PermissionDeniedScreen extends StatelessWidget {
  final PermissionResult permissionResult;

  const PermissionDeniedScreen({super.key, required this.permissionResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Permisos Requeridos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'AguaLector necesita acceso a la cámara y ubicación para funcionar correctamente.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Lista de permisos y su estado
              _buildPermissionTile(
                'Cámara',
                Icons.camera_alt,
                permissionResult.cameraGranted,
              ),
              const SizedBox(height: 12),
              _buildPermissionTile(
                'Ubicación (GPS)',
                Icons.location_on,
                permissionResult.locationGranted,
              ),

              const SizedBox(height: 40),

              // Botón para reintentar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final permissionService = PermissionService();
                    final result = await permissionService
                        .requestAllPermissions();

                    if (context.mounted) {
                      if (result.allGranted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ListaContadoresScreen(),
                          ),
                        );
                      } else {
                        // Recargar pantalla con nuevo estado
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PermissionDeniedScreen(
                              permissionResult: result,
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('SOLICITAR PERMISOS'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Texto informativo si fueron denegados permanentemente
              if (permissionResult.anyPermanentlyDenied)
                const Text(
                  'Si los permisos fueron denegados permanentemente, '
                  'debes habilitarlos manualmente en la configuración del dispositivo.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile(String name, IconData icon, bool granted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: granted ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: granted ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: granted ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
