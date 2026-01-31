# Manual Técnico - GuapoLector v1.3.0

## Arquitectura del Sistema

### Stack Tecnológico

| Componente    | Tecnología                 | Versión        |
| ------------- | -------------------------- | -------------- |
| Framework     | Flutter                    | ^3.10.7        |
| Lenguaje      | Dart                       | ^3.x           |
| Base de datos | SQLite                     | sqflite ^2.3.0 |
| Cámara        | camera                     | ^0.11.0+2      |
| GPS           | geolocator                 | ^10.1.0        |
| Permisos      | permission_handler         | ^11.3.0        |
| Mapas         | flutter_map                | ^6.1.0         |
| Clustering    | flutter_map_marker_cluster | ^1.3.6         |
| Exportación   | csv, share_plus, archive   | Latest         |

---

## Estructura del Proyecto (v1.3.0)

La aplicación sigue una arquitectura de servicios desacoplada para facilitar el mantenimiento.

```
app/
├── lib/
│   ├── main.dart              # Punto de entrada y configuración de la App
│   ├── config/
│   │   ├── theme.dart         # Colores, tipografía y diseño visual
│   │   └── constants.dart     # Centralización de lógica (Ciclos, DB, Versión)
│   ├── models/
│   │   ├── contador.dart      # Entidad Contador de agua
│   │   └── lectura.dart       # Entidad Registro de toma
│   ├── screens/
│   │   ├── splash_screen.dart             # Carga inicial y syncing
│   │   ├── lista_contadores_screen.dart   # Vista principal (Filtros y lista)
│   │   ├── map_screen.dart                # Visualización geográfica interactiva
│   │   ├── registro_lectura_screen.dart   # Captura (Cámara + GPS)
│   │   ├── confirmacion_screen.dart       # Feedback post-guardado
│   │   ├── historial_screen.dart          # Reportes y Exportación
│   │   └── permission_denied_screen.dart  # Gestión de errores de sistema
│   ├── services/
│   │   ├── database_service.dart          # CRUD persistente (SQLite)
│   │   ├── camera_service.dart            # Captura y manipulación de archivos
│   │   ├── gps_service.dart               # Geolocalización y precisión
│   │   ├── permission_service.dart        # Flujo de permisos de SO
│   │   ├── export_service.dart            # Generación CSV/ZIP (Uso de Isolates)
│   │   └── csv_import_service.dart        # Parsing de Maestro semilla
│   └── widgets/
│       ├── counter_marker.dart            # Marcador optimizado para mapa
│       ├── gps_indicator.dart             # Señal de estado de ubicación
│       └── ...
├── android/
├── test/
│   ├── logic_test.dart        # Lógica de ciclos de 15 días
│   ├── gps_service_test.dart  # Resiliencia de ubicación
│   └── widget_test.dart       # Smoke tests de UI
└── ...
```

---

## Gestión de Lógica de Negocio (Single Source of Truth)

En la versión **v1.3.0**, toda la configuración crítica se centralizó en `lib/config/constants.dart`:

- `diasCicloLectura`: Define la ventana de edición (15 días por defecto).
- `dbVersion`: Controla las migraciones de SQLite.
- `appVersion`: Valor único para UI y reportes.

---

## Modelos de Datos

### Contador (`Contador`)
Representa el medidor físico.
- `id`: String (Código concatenado).
- `nombre`: String (Suscriptor).
- `vereda`: String.
- `lote`: String? (Opcional).
- `ultimaLectura`: double? (Del mes anterior).
- `estado`: Enum (pendiente, registrado, conError).
- `latitud`, `longitud`: double? (Ubicación fija del medidor).

### Lectura (`Lectura`)
Representa la acción de toma de datos.
- `lectura`: double? (Consumo actual, null si hay excepción).
- `fotoPath`: String (Ruta local de la evidencia).
- `comentario`: String? (Motivo de no lectura).
- `sincronizado`: bool.

---

## Base de Datos SQLite

### Migraciones Recientes (v5)
La versión 5 del esquema habilitó las coordenadas `REAL` en la tabla de contadores para permitir el despliegue del mapa interactivo sin depender de datos previos en la tabla de lecturas.

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
```

---

## Sistema de Mapa de Alto Rendimiento

Optimizado para manejar cientos de puntos sin degradación de la UI:

1. **Reactive State:** Uso de `ValueNotifier` para rotación y zoom, evitando reconstrucciones del widget `Map` completo.
2. **Clustering Dinámico:** Agrupación de marcadores mediante `flutter_map_marker_cluster` ajustada según el nivel de zoom.
3. **Caché de Imágenes:** El sistema evita el re-renderizado de iconos de medidores mediante el uso de widgets con `const` y `CounterMarker`.
4. **Persistencia de Cámara:** El `MapService` actúa como Singleton guardando la última posición del usuario para evitar desorientación al navegar entre pantallas.

---

## Exportación de Datos (Isolates)

Debido a que el empaquetado de imágenes (ZIP) y el procesamiento de CSVs largos puede bloquear el hilo principal (UI Thread), el `ExportService` utiliza la función `compute` de Flutter.

- **Proceso:** La compresión ZIP se delega a un Isolate separado.
- **Feedback:** Se emite un flujo de `ExportProgress` para mostrar porcentaje real, tamaño estimado y tiempo restante al usuario en `HistorialScreen`.

---

## Estrategia de Testing (v1.3.0)

Se ha mejorado la suite de pruebas para cubrir casos de sincronización de frames:

### 1. Pruebas de UI (`widget_test.dart`)
Debido a que el `SplashScreen` utiliza animaciones complejas y timers de inicialización, las pruebas deben utilizar:
```dart
await tester.pumpWidget(const AguaLectorApp());
await tester.pump(const Duration(seconds: 4)); // Limpieza de Timers
```

### 2. Pruebas de Logica (`logic_test.dart`)
Valida el **Rollover Automático**. Si la fecha de la primera toma del dispositivo tiene más de 15 días (`AppConstants.diasCicloLectura`), el sistema automáticamente marca las lecturas como no editables y las prepara para limpieza.

---

## Consideraciones de Rendimiento

- **Imágenes:** Se capturan a calidad 80 y resolución media para balancear nitidez y espacio en disco.
- **GPS:** Se utiliza un timeout de 10 segundos. Si falla, el sistema permite guardar indicando "Sin GPS" en el metadato, priorizando la continuidad de la operación.
- **Memoria:** Se implementó `WidgetsBindingObserver` en la cámara para liberar recursos inmediatamente cuando la app pasa a segundo plano.

---

*Manual actualizado el 2026-01-31 por Antigravity.*
