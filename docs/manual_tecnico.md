# Manual Técnico - GuapoLector

## Arquitectura del Sistema

### Stack Tecnológico

| Componente    | Tecnología               | Versión     |
| ------------- | ------------------------ | ----------- |
| Framework     | Flutter                  | 3.x         |
| Lenguaje      | Dart                     | 3.x         |
| Base de datos | SQLite                   | sqflite 2.x |
| Cámara        | camera                   | Latest      |
| GPS           | geolocator               | Latest      |
| Permisos      | permission_handler       | Latest      |
| Exportación   | csv, share_plus, archive | Latest      |

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

> En la versión **v1.2.0**, se implementó una optimización masiva del motor de mapas, introduciendo lógica de clustering $O(1)$ y desacoplamiento de estado mediante `ValueNotifiers`, garantizando fluidez de 60fps constantes. Se mantiene la lógica de ventana de edición de 15 días y auto-limpieza de fotos instaurada anteriormente.

---

## Inicialización y Primer Inicio

La aplicación está diseñada para operar "fuera de la caja" (out-of-the-box) mediante un proceso de importación automática de datos semilla.

### Proceso de Importación (Primer Inicio)
Al abrir la aplicación por primera vez, el `CsvImportService` se activa automáticamente si detecta que la base de datos de contadores está vacía. 
1. Busca el archivo `assets/LECTURAS_PILOTO.csv` dentro del paquete de la app.
2. Procesa los registros y los inserta en la tabla `contadores`.
3. Establece la lectura histórica como `ultima_lectura` y deja el estado del medidor en `pendiente`.

### Propuesta Práctica de Inicialización
Para configurar la aplicación con datos reales de una nueva comunidad o periodo:

1. **Preparar el Archivo CSV:** 
   Utilizar una plantilla de Excel y exportarla a CSV con codificación UTF-8 (delimitado por comas). Debe contener las siguientes columnas obligatorias:
   - `CODIGO_CONCATENADO`: ID único del medidor.
   - `NOMBRE_COMPLETO`: Nombre del suscriptor.
   - `VEREDA`: Sector geográfico.
   - `HISTORICO_DIC`: El valor de la última lectura realizada (servirá como base de comparación).

2. **Actualizar Asset:**
   Reemplazar el archivo en `app/assets/LECTURAS_PILOTO.csv` con el nuevo archivo.

3. **Compilar y Desplegar:**
   Al instalar el APK, la aplicación detectará que es la primera ejecución y cargará el nuevo listado automáticamente.

> [!TIP]
> Si se desea forzar una re-inicialización en un dispositivo que ya tiene datos, se debe ir a *Ajustes > Aplicaciones > GuapoLector > Almacenamiento > Borrar Datos*. Esto eliminará la base de datos SQLite y disparará la importación del CSV en el siguiente inicio.

### Actualización de Suscriptores o Información
Si durante la operación se requiere agregar nuevos usuarios o corregir nombres en la lista maestra, se debe seguir este flujo práctico:

1. **Modificación del Maestro:**
   Actualizar el archivo fuente (Excel) agregando las nuevas filas o corrigiendo los campos necesarios. Asegurarse de asignar un `CODIGO_CONCATENADO` único a los nuevos usuarios.

2. **Actualización del Asset:**
   Sustituir el archivo `app/assets/LECTURAS_PILOTO.csv` en el código fuente.

3. **Ciclo de Vida de Datos:**
   Debido a que SQLite es persistente, instalar una nueva versión del APK sobre una existente **no borrará** los usuarios antiguos ni cargará los nuevos automáticamente (para proteger las lecturas ya tomadas). 

4. **Procedimiento Recomendado para Administradores:**
   - **Opción A (Nueva instalación):** Desinstalar la versión anterior e instalar la nueva. Esto garantiza que todos los teléfonos arranquen con la lista actualizada al 100%.
   - **Opción B (Mantenimiento remoto):** En futuras versiones se implementará un botón de "Sincronizar Maestro" para evitar la pérdida de datos, pero para la fase piloto, la **Re-inicialización** (borrar datos de la app) es el método más seguro y rápido.

---

## Modelos de Datos

### Contador

```dart
class Contador {
  final String id;
  final String nombre;
  final String vereda;
  final String? lote;
  final double? ultimaLectura;
  final DateTime? fechaUltimaLectura;
  final EstadoContador estado;
  final double? latitud;  // Coordenada GPS estática
  final double? longitud; // Coordenada GPS estática
}
```

### Lectura

```dart
class Lectura {
  final int id;
  final String contador_id;
  final String nombre_usuario;
  final String vereda;
  final double? lectura; // Nullable para anomalías
  final String foto_path;
  final double? latitud;  // Ubicación al momento de la toma
  final double? longitud; // Ubicación al momento de la toma
  final DateTime fecha;
  final bool sincronizado;
  final String? comentario;
}
```

---

## Base de Datos SQLite

### Esquema

```sql
CREATE TABLE contadores (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  vereda TEXT NOT NULL,
  lote TEXT,
  ultima_lectura REAL,
  fecha_ultima_lectura TEXT,
  estado TEXT,
  latitud REAL,
  longitud REAL
);

CREATE TABLE lecturas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  contador_id TEXT NOT NULL,
  nombre_usuario TEXT NOT NULL,
  vereda TEXT NOT NULL,
  lectura REAL,
  foto_path TEXT NOT NULL,
  latitud REAL,
  longitud REAL,
  fecha TEXT NOT NULL,
  sincronizado INTEGER DEFAULT 0,
  comentario TEXT,
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
  Future<void> updateContadorUbicacion(String id, double lat, double lng);
  Future<void> insertLectura(Lectura lectura);
  Future<Lectura?> getLecturaActiva(String contadorId);
  Future<void> limpiarYActualizarRegistros();
}
```

### MapService

```dart
class MapService {
  Future<List<Contador>> getContadoresConUbicacion();
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
  Future<void> exportarLecturas({List<Lectura>? lecturasFiltradas, String? veredaFiltro});
}
```

### CsvImportService

```dart
class CsvImportService {
  Future<void> importInitialData();
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
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
  csv: ^6.0.0
  share_plus: ^10.0.0
  archive: ^3.6.1
  intl: ^0.19.0
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

---

## Sistema de Mapa de Alto Rendimiento (v1.2.0)

El módulo de mapas ha sido optimizado para máximo rendimiento:

- **Motor O(1):** Uso de `ContadorMarker` para acceso directo a estados en el builder de clusters.
- **Desacoplamiento Reactivo:** Implementación de `ValueNotifiers` y `ValueListenableBuilder` para aislar los repintados de la cámara (zoom/rotation) del resto de la aplicación.
- **Persistencia de Estado:** Singleton en `MapService` que almacena `lastCenter`, `lastZoom` y `lastRotation`.
- **Caché:** Integración de `flutter_map_cache` con `MemCacheStore`.

### Arquitectura y Flujo de Datos
- **Manejo de Coordenadas:** Se utilizan las coordenadas almacenadas en la tabla `contadores` (ubicación fija).
- **Diferenciación de Estados:**
    - **🟢 Verde**: Registro completado en el ciclo actual.
    - **🔴 Rojo/Gris**: Pendiente de lectura.
- **Capa de Interacción:** Bottom Sheet Expandible (`DraggableScrollableSheet`) para detalles y acciones rápidas.

### Importación de Coordenadas
El `CsvImportService` permite actualizar `LATITUD` y `LONGITUD` mediante el archivo CSV maestro sin afectar lecturas previas.

---

## Consideraciones de Rendimiento

- **Cámara:** Resolución baja por defecto (`ResolutionPreset.low`) para ahorrar CPU y RAM.
- **Ciclo de Vida:** Control estricto de recursos de cámara con `WidgetsBindingObserver`.
- **UI:** Uso de `RepaintBoundary` para la vista previa de cámara en vivo para evitar repintados innecesarios del resto de la interfaz.
- **GPS:** Uso de `getLastKnownLocation()` como primera opción para evitar esperas y consumo excesivo de batería.
- **Imágenes:** Guardadas con nombres de archivo basados en timestamp para evitar colisiones.
- **Isolates:** Uso de `compute` para operaciones de I/O pesadas (compresión ZIP) para mantener la tasa de refresco de la UI estable.
- Limpieza Temporal:** De eliminación de archivos físicas tras 15 días para prevenir el agotamiento de almacenamiento interno.

---

## Estrategia de Pruebas

El proyecto cuenta con una suite de pruebas automatizadas ubicadas en el directorio `app/test/` para garantizar la estabilidad de las funciones críticas.

### 1. Pruebas de Logica de Negocio (`logic_test.dart`)
Verifica el núcleo de la lógica del ciclo de facturación de 15 días:
- **Ciclo Activo**: Confirma que las lecturas son editables si la primera toma del mes fue hace menos de 15 días.
- **Ciclo Vencido**: Asegura que se bloquee la edición después de 15 días.
- **Rollover**: Valida que el sistema marque correctamente cuándo se debe limpiar el historial y comenzar un nuevo periodo.

### 2. Pruebas de Servicios (`gps_service_test.dart`)
Valida la resiliencia del servicio de geolocalización:
- **Manejo de Errores**: Simula fallos en el plugin `geolocator` para asegurar que la app no se cierre inesperadamente y devuelva un objeto `GpsResult` con `success: false`.

### 3. Pruebas de Interfaz (`widget_test.dart`)
Pruebas de humo (smoke tests) para la UI:
- **Splash Screen**: Verifica que la aplicación inicie correctamente, muestre el logo y la versión v1.0.0.
- **Navegación**: Valida el flujo inicial de carga de la aplicación.

### Ejecución de Pruebas
Para ejecutar todas las pruebas automatizadas:

```bash
flutter test
```
---

## Flujo de Trabajo Git

Ver `README.md` para detalles del flujo de trabajo con ramas `main` y `dev`.

---

## Hoja de Ruta y Desarrollos Futuros

Para las siguientes fases del proyecto, se contemplan las siguientes mejoras arquitectónicas:

### 1. Ordenamiento Inteligente por Ubicación
- **Objetivo:** Optimizar los tiempos de desplazamiento del lector en campo.
- **Implementación:** Organizar automáticamente la lista de contadores basándose en la jerarquía `Vereda > Ruta > Predio`. De esta forma, el siguiente medidor en la lista será siempre el físicamente más cercano al anterior, reduciendo errores y fatiga.

### 2. Gestión Externa de Usuarios (PC Tool)
- **Objetivo:** Facilitar la administración de la base de datos sin depender de actualizaciones de APK.
- **Propuesta:** Desarrollo de una aplicación de escritorio (GuapoLector Admin) que, al conectar el dispositivo móvil al PC vía USB:
  - Permita leer la base de datos actual.
  - Permita inyectar nuevos suscriptores desde un Excel/CSV de forma masiva.
  - Permita corregir información de usuarios existentes directamente en el dispositivo.

### 4. Gestión de Excepciones de Lectura (v0.9.0)
- **Implementación:** Si el contador no es legible, el usuario activa el diálogo de excepción. Se registra una lectura técnica de `0 m³` y se guarda el motivo descriptivo. **La toma de fotografía es obligatoria incluso en este caso** para dejar constancia visual de la situación (ej. perro agresivo, contador obstruido). En el CSV exportado, este motivo aparece en la columna `MOTIVO_NO_LECTURA`.
