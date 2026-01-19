import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Resultado de obtención de GPS
class GpsResult {
  final bool success;
  final double? latitude;
  final double? longitude;
  final String? errorMessage;

  GpsResult({
    required this.success,
    this.latitude,
    this.longitude,
    this.errorMessage,
  });

  factory GpsResult.success(double lat, double lng) {
    return GpsResult(success: true, latitude: lat, longitude: lng);
  }

  factory GpsResult.error(String message) {
    return GpsResult(success: false, errorMessage: message);
  }
}

/// Servicio para obtención de ubicación GPS
class GpsService {
  /// Timeout para obtener ubicación (segundos)
  static const int timeoutSeconds = 10;

  /// Verifica si el servicio de ubicación está habilitado
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Solicita permisos de ubicación
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Verifica el estado actual de los permisos
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Obtiene la ubicación actual
  Future<GpsResult> getCurrentLocation() async {
    try {
      // Verificar si el servicio está habilitado
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return GpsResult.error('GPS desactivado. Actívalo en ajustes.');
      }

      // Verificar/solicitar permiso
      var permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return GpsResult.error('Permiso de ubicación denegado.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return GpsResult.error(
          'Permiso denegado permanentemente. Habilita en ajustes.',
        );
      }

      // Obtener posición
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: timeoutSeconds),
      );

      return GpsResult.success(position.latitude, position.longitude);
    } catch (e) {
      return GpsResult.error('Error obteniendo ubicación: $e');
    }
  }

  /// Obtiene la última ubicación conocida (más rápido pero menos preciso)
  Future<GpsResult> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        return GpsResult.success(position.latitude, position.longitude);
      }
      // Si no hay última ubicación, intentar obtener la actual
      return getCurrentLocation();
    } catch (e) {
      return GpsResult.error('Error: $e');
    }
  }
}
