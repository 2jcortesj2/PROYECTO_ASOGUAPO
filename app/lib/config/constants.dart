/// Constantes globales de la aplicación AguaLector

class AppConstants {
  // Nombre de la app
  static const String appName = 'AguaLector';
  static const String appVersion = '0.1.0';

  // Base de datos
  static const String dbName = 'agualector.db';
  static const int dbVersion = 1;

  // GPS
  static const int gpsTimeoutSeconds = 10;
  static const double gpsDesiredAccuracy = 10.0; // metros

  // Cámara
  static const int imageQuality = 80; // 0-100
  static const int maxImageWidth = 1280;
  static const int maxImageHeight = 960;

  // UI
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 56.0;
  static const double minTouchTarget = 48.0;

  // Validaciones
  static const double lecturaMinima = 0.0;
  static const double lecturaMaxima = 999999.0;

  // Exportación
  static const String csvDelimiter = ';';
  static const String csvFileName = 'lecturas_agualector';
}

/// Estados posibles de un contador
enum EstadoContador { pendiente, registrado, conError }

/// Extensión para obtener el nombre legible del estado
extension EstadoContadorExtension on EstadoContador {
  String get nombre {
    switch (this) {
      case EstadoContador.pendiente:
        return 'Pendiente';
      case EstadoContador.registrado:
        return 'Registrado';
      case EstadoContador.conError:
        return 'Con error';
    }
  }
}
