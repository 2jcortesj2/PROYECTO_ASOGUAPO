# Manual Técnico - AguaLector

## Arquitectura del Sistema

### Stack Tecnológico

| Componente    | Tecnología         | Versión     |
| ------------- | ------------------ | ----------- |
| Framework     | Flutter            | 3.x         |
| Lenguaje      | Dart               | 3.x         |
| Base de datos | SQLite             | sqflite 2.x |
| Cámara        | camera             | Latest      |
| GPS           | geolocator         | Latest      |
| Permisos      | permission_handler | Latest      |
| Exportación   | csv, share_plus    | Latest      |

---

## Estructura del Proyecto

```
app/
├── lib/
│   ├── main.dart              # Punto de entrada
│   ├── app.dart               # Configuración de MaterialApp
│   ├── config/
│   │   ├── theme.dart         # Colores, tipografía
│   │   └── constants.dart     # Constantes globales
│   ├── models/
│   │   ├── contador.dart      # Modelo de contador
│   │   └── lectura.dart       # Modelo de lectura
│   ├── screens/
│   │   ├── lista_contadores_screen.dart
│   │   ├── registro_lectura_screen.dart
│   │   ├── confirmacion_screen.dart
│   │   └── historial_screen.dart
│   ├── widgets/
│   │   ├── contador_card.dart
│   │   ├── lectura_input.dart
│   │   ├── gps_indicator.dart
│   │   └── boton_principal.dart
│   ├── services/
│   │   ├── database_service.dart
│   │   ├── camera_service.dart
│   │   ├── gps_service.dart
│   │   ├── permission_service.dart
│   │   └── export_service.dart
│   └── utils/
│       └── formatters.dart
├── android/
├── test/
│   └── widget_test.dart       # Pruebas de UI
├── docs/
│   ├── manual_usuario.md
│   ├── manual_tecnico.md
│   └── TESTING.md             # Guía de testing
├── pubspec.yaml
└── pubspec.lock
```

> [!NOTE]
> En la versión **v0.3.0**, se ha implementado la cámara real embebida (con el paquete `camera`) y el sistema de permisos al inicio de la aplicación. La persistencia en base de datos aún se encuentra en proceso de integración final.

---

## Modelos de Datos

### Contador

```dart
class Contador {
  final String id;
  final String nombre;
  final String sector;
  final String? lote;
  final double? ultimaLectura;
  final DateTime? fechaUltimaLectura;
  final bool tieneRegistroHoy;
}
```

### Lectura

```dart
class Lectura {
  final int id;
  final String contadorId;
  final String nombreUsuario;
  final String sector;
  final double lectura;
  final String fotoPath;
  final double? latitud;
  final double? longitud;
  final DateTime fecha;
  final bool sincronizado;
}
```

---

## Base de Datos SQLite

### Esquema

```sql
CREATE TABLE contadores (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  sector TEXT,
  lote TEXT,
  ultima_lectura REAL,
  fecha_ultima_lectura TEXT
);

CREATE TABLE lecturas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  contador_id TEXT NOT NULL,
  nombre_usuario TEXT NOT NULL,
  sector TEXT,
  lectura REAL NOT NULL,
  foto_path TEXT NOT NULL,
  latitud REAL,
  longitud REAL,
  fecha TEXT NOT NULL,
  sincronizado INTEGER DEFAULT 0,
  FOREIGN KEY (contador_id) REFERENCES contadores(id)
);

CREATE INDEX idx_lecturas_fecha ON lecturas(fecha);
CREATE INDEX idx_lecturas_contador ON lecturas(contador_id);
```

---

## Servicios

### DatabaseService

```dart
class DatabaseService {
  Future<Database> get database;
  Future<List<Contador>> getContadores();
  Future<void> insertLectura(Lectura lectura);
  Future<List<Lectura>> getLecturasPorFecha(DateTime fecha);
  Future<void> marcarSincronizado(int id);
}
```

### GpsService

```dart
class GpsService {
  Future<bool> isLocationServiceEnabled();
  Future<GpsResult> getCurrentLocation();
  Future<GpsResult> getLastKnownLocation();
}
```

### PermissionService

```dart
class PermissionService {
  Future<PermissionResult> requestAllPermissions();
  Future<PermissionResult> checkPermissions();
}
```

### ExportService

```dart
class ExportService {
  Future<String> exportToCsv(List<Lectura> lecturas);
  Future<void> shareFile(String filePath);
}
```

---

## Permisos Android

`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

---

## Dependencias (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path_provider: ^2.1.2
  camera: ^0.11.0+2
  permission_handler: ^11.3.0
  geolocator: ^10.1.0
  csv: ^5.1.0
  share_plus: ^7.2.0
  intl: ^0.18.0
  provider: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## Compilación

### Debug

```bash
cd app
flutter run
```

### Release APK

```bash
flutter build apk --release
```

El APK se genera en: `build/app/outputs/flutter-apk/app-release.apk`

---

## Consideraciones de Rendimiento

- **Cámara:** Resolución baja por defecto (`ResolutionPreset.low`) para ahorrar CPU y RAM.
- **Ciclo de Vida:** Control estricto de recursos de cámara con `WidgetsBindingObserver`.
- **UI:** Uso de `RepaintBoundary` para la vista previa de cámara en vivo para evitar repintados innecesarios del resto de la interfaz.
- **GPS:** Uso de `getLastKnownLocation()` como primera opción para evitar esperas y consumo excesivo de batería.
- **Imágenes:** Guardadas con nombres de archivo basados en timestamp para evitar colisiones y organizadas en subdirectorios.

---

## Flujo de Trabajo Git

Ver `README.md` para detalles del flujo de trabajo con ramas `main` y `dev`.
