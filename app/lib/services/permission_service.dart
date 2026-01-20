import 'package:permission_handler/permission_handler.dart';

/// Resultado de la solicitud de permisos
class PermissionResult {
  final bool cameraGranted;
  final bool locationGranted;
  final bool allGranted;
  final bool anyPermanentlyDenied;

  PermissionResult({required this.cameraGranted, required this.locationGranted})
    : allGranted = cameraGranted && locationGranted,
      anyPermanentlyDenied = false;

  PermissionResult._internal({
    required this.cameraGranted,
    required this.locationGranted,
    required this.anyPermanentlyDenied,
  }) : allGranted = cameraGranted && locationGranted;

  factory PermissionResult.withDenied({
    required bool cameraGranted,
    required bool locationGranted,
    required bool anyPermanentlyDenied,
  }) {
    return PermissionResult._internal(
      cameraGranted: cameraGranted,
      locationGranted: locationGranted,
      anyPermanentlyDenied: anyPermanentlyDenied,
    );
  }
}

/// Servicio centralizado para manejar permisos de la aplicación
/// Solicita todos los permisos necesarios al inicio para evitar interrupciones
class PermissionService {
  /// Solicita todos los permisos necesarios de una vez
  /// Retorna el resultado con el estado de cada permiso
  Future<PermissionResult> requestAllPermissions() async {
    // Solicitar todos los permisos en paralelo
    final results = await [Permission.camera, Permission.location].request();

    final cameraStatus = results[Permission.camera]!;
    final locationStatus = results[Permission.location]!;

    // Verificar si alguno fue denegado permanentemente
    final anyPermanentlyDenied =
        cameraStatus.isPermanentlyDenied || locationStatus.isPermanentlyDenied;

    return PermissionResult.withDenied(
      cameraGranted: cameraStatus.isGranted,
      locationGranted: locationStatus.isGranted,
      anyPermanentlyDenied: anyPermanentlyDenied,
    );
  }

  /// Verifica el estado actual de los permisos sin solicitarlos
  Future<PermissionResult> checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final locationStatus = await Permission.location.status;

    return PermissionResult.withDenied(
      cameraGranted: cameraStatus.isGranted,
      locationGranted: locationStatus.isGranted,
      anyPermanentlyDenied:
          cameraStatus.isPermanentlyDenied ||
          locationStatus.isPermanentlyDenied,
    );
  }

  /// Verifica si el permiso de cámara está concedido
  Future<bool> isCameraGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Verifica si el permiso de ubicación está concedido
  Future<bool> isLocationGranted() async {
    return await Permission.location.isGranted;
  }

  /// Abre la configuración del sistema para que el usuario
  /// pueda habilitar permisos denegados permanentemente
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}
