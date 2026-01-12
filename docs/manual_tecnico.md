# Manual Técnico - AguaLector

## Arquitectura del Sistema

### Stack Tecnológico

| Componente    | Tecnología            | Versión     |
| ------------- | --------------------- | ----------- |
| Framework     | Flutter               | 3.x         |
| Lenguaje      | Dart                  | 3.x         |
| Base de datos | SQLite                | sqflite 2.x |
| Cámara        | camera / image_picker | Latest      |
| GPS           | geolocator            | Latest      |
| Exportación   | csv, share_plus       | Latest      |

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
│   │   └── export_service.dart
│   └── utils/
│       └── formatters.dart
├── android/
├── pubspec.yaml
└── pubspec.lock
```

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
  Future<bool> checkPermissions();
  Future<Position?> getCurrentPosition();
  Stream<ServiceStatus> get serviceStatusStream;
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
  path_provider: ^2.1.0
  camera: ^0.10.5
  image_picker: ^1.0.0
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

- **Imágenes:** Comprimidas a 80% calidad JPEG, máx 1280px
- **Base de datos:** Índices en campos de fecha y contador_id
- **GPS:** Timeout de 10 segundos con opción de continuar sin ubicación
- **Memoria:** Límite de 50 registros en memoria, paginación para historial

---

## Flujo de Trabajo Git

Ver `README.md` para detalles del flujo de trabajo con ramas `main` y `dev`.
