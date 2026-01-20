# Documentación Técnica - Gestión de Base de Datos SQLite

## Arquitectura de Datos

### Modelo Entidad-Relación

```
┌─────────────────────────────┐
│       CONTADORES            │
├─────────────────────────────┤
│ PK  id (TEXT)               │
│     nombre (TEXT)           │
│     vereda (TEXT)           │
│     lote (TEXT)             │
│     ultima_lectura (REAL)   │
│     fecha_ultima_lectura    │
│     estado (TEXT)           │
└─────────────────────────────┘
           │
           │ 1:N
           ▼
┌─────────────────────────────┐
│        LECTURAS             │
├─────────────────────────────┤
│ PK  id (INTEGER)            │
│ FK  contador_id (TEXT)      │
│     nombre_usuario (TEXT)   │
│     vereda (TEXT)           │
│     lectura (REAL)          │
│     foto_path (TEXT)        │
│     latitud (REAL)          │
│     longitud (REAL)         │
│     fecha (TEXT)            │
│     sincronizado (INTEGER)  │
└─────────────────────────────┘
```

## Esquema de Base de Datos

### Tabla: `contadores`

Almacena el padrón de usuarios/medidores del sistema.

```sql
CREATE TABLE contadores (
  id TEXT PRIMARY KEY,              -- Código concatenado (ej: "PUE-102-9")
  nombre TEXT NOT NULL,             -- Nombre completo del usuario
  vereda TEXT NOT NULL,             -- Vereda/Sector (El Recreo, Pueblo Nuevo, El Tendido)
  lote TEXT,                        -- Lote/Predio (opcional)
  ultima_lectura REAL,              -- Última lectura registrada (referencia histórica)
  fecha_ultima_lectura TEXT,        -- Fecha de la última lectura (ISO 8601)
  estado TEXT                       -- Estado: 'pendiente', 'registrado', 'conError'
);
```

**Índices:**
- PRIMARY KEY en `id`

**Estados posibles:**
- `pendiente`: Sin lectura para el periodo actual
- `registrado`: Con lectura registrada para hoy
- `conError`: Lectura con problemas de validación

---

### Tabla: `lecturas`

Almacena el historial de lecturas tomadas con la aplicación.

```sql
CREATE TABLE lecturas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID autoincremental
  contador_id TEXT NOT NULL,             -- FK a contadores.id
  nombre_usuario TEXT NOT NULL,          -- Nombre del usuario (desnormalizado para reportes)
  vereda TEXT NOT NULL,                  -- Vereda (desnormalizado para reportes)
  lectura REAL NOT NULL,                 -- Valor de la lectura en m³
  foto_path TEXT NOT NULL,               -- Ruta local de la foto del medidor
  latitud REAL,                          -- Coordenada GPS (opcional)
  longitud REAL,                         -- Coordenada GPS (opcional)
  fecha TEXT NOT NULL,                   -- Fecha/hora de captura (ISO 8601)
  sincronizado INTEGER DEFAULT 0,        -- 0 = no sincronizado, 1 = sincronizado
  FOREIGN KEY (contador_id) REFERENCES contadores(id)
);

-- Índices para optimización
CREATE INDEX idx_lecturas_fecha ON lecturas(fecha);
CREATE INDEX idx_lecturas_contador ON lecturas(contador_id);
```

**Índices:**
- PRIMARY KEY en `id`
- INDEX en `fecha` (para consultas por periodo)
- INDEX en `contador_id` (para consultas por usuario)
- FOREIGN KEY a `contadores(id)`

---

## Operaciones CRUD

### DatabaseService - Métodos Principales

#### Contadores

```dart
// Insertar o actualizar contador
Future<int> insertContador(Contador contador)
  → INSERT con ConflictAlgorithm.replace

// Obtener todos los contadores
Future<List<Contador>> getContadores()
  → SELECT * FROM contadores

// Obtener contador por ID
Future<Contador?> getContadorById(String id)
  → SELECT * FROM contadores WHERE id = ?

// Actualizar estado de contador
Future<void> updateEstadoContador(String id, EstadoContador estado)
  → UPDATE contadores SET estado = ? WHERE id = ?
```

#### Lecturas

```dart
// Insertar nueva lectura
Future<int> insertLectura(Lectura lectura)
  → INSERT INTO lecturas
  → UPDATE estado del contador a 'registrado'

// Obtener todas las lecturas (ordenadas por fecha DESC)
Future<List<Lectura>> getLecturas()
  → SELECT * FROM lecturas ORDER BY fecha DESC

// Verificar si existe lectura HOY para un contador
Future<Lectura?> getLecturaPorContadorHoy(String contadorId)
  → SELECT * FROM lecturas 
    WHERE contador_id = ? 
    ORDER BY fecha DESC LIMIT 1
  → Validación estricta: mismo día/mes/año que hoy

// Actualizar lectura existente
Future<void> updateLectura(Lectura lectura)
  → UPDATE lecturas SET ... WHERE id = ?
```

#### Utilidades

```dart
// Limpiar todas las tablas (solo para desarrollo/testing)
Future<void> deleteAllContadores()
Future<void> deleteAllLecturas()
```

---

## Flujo de Datos

### 1. Importación Inicial (CSV → SQLite)

```
LECTURAS_PILOTO.csv
        ↓
CsvImportService.importInitialData()
        ↓
┌─────────────────────────────────────┐
│ Por cada fila del CSV:              │
│ 1. Parse datos (nombre, vereda)    │
│ 2. Crear Contador con:             │
│    - ultimaLectura = HISTORICO_DIC │
│    - estado = PENDIENTE            │
│ 3. INSERT en tabla 'contadores'    │
│ 4. NO insertar en 'lecturas'       │
└─────────────────────────────────────┘
        ↓
Base de datos lista para Enero
(sin registros en tabla 'lecturas')
```

**Importante:** Las lecturas históricas del CSV **NO** se insertan en la tabla `lecturas`. Solo se usan como referencia en `ultima_lectura` del contador.

---

### 2. Registro de Nueva Lectura

```
Usuario toca contador PENDIENTE
        ↓
RegistroLecturaScreen
        ↓
┌─────────────────────────────────────┐
│ 1. Captura foto (CameraService)    │
│ 2. Obtiene GPS (GpsService)        │
│ 3. Usuario ingresa lectura         │
│ 4. Crea objeto Lectura             │
└─────────────────────────────────────┘
        ↓
DatabaseService.insertLectura()
        ↓
┌─────────────────────────────────────┐
│ TRANSACCIÓN:                        │
│ 1. INSERT INTO lecturas             │
│ 2. UPDATE contadores                │
│    SET estado = 'registrado'        │
└─────────────────────────────────────┘
        ↓
Navegación a ConfirmacionScreen
```

---

### 3. Verificación de Lectura Existente

```
Usuario toca contador
        ↓
ListaContadoresScreen._abrirRegistro()
        ↓
DatabaseService.getLecturaPorContadorHoy()
        ↓
┌─────────────────────────────────────┐
│ SELECT * FROM lecturas              │
│ WHERE contador_id = ?               │
│ ORDER BY fecha DESC LIMIT 1         │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ Validación estricta de fecha:      │
│ lectura.fecha.year == now.year &&  │
│ lectura.fecha.month == now.month && │
│ lectura.fecha.day == now.day        │
└─────────────────────────────────────┘
        ↓
Si existe HOY → Mostrar diálogo "Usuario ya registrado"
Si NO existe → Abrir RegistroLecturaScreen
```

---

### 4. Exportación de Datos

```
Usuario presiona botón EXPORTAR
        ↓
ExportService.exportarLecturas()
        ↓
┌─────────────────────────────────────┐
│ 1. SELECT * FROM lecturas           │
│ 2. SELECT * FROM contadores         │
│ 3. JOIN en memoria (Map lookup)    │
│ 4. Calcular consumo:                │
│    lectura_actual - lectura_anterior│
└─────────────────────────────────────┘
        ↓
Generar CSV con columnas:
- CODIGO_CONCATENADO
- NOMBRE_COMPLETO
- VEREDA
- LECTURA_ANTERIOR
- LECTURA_ACTUAL
- CONSUMO
- FECHA_LECTURA
- HORA_LECTURA
- LATITUD
- LONGITUD
- RUTA_FOTO
        ↓
Guardar en Documents/lecturas_export_YYYYMMDD_HHMM.csv
        ↓
Compartir vía Share API (WhatsApp, Email, etc.)
```

---

## Diagrama de Flujo - Ciclo de Vida de una Lectura

```
┌─────────────────────────────────────────────────────────────┐
│                    INICIO DE MES                            │
│  CSV Import: Contadores en estado PENDIENTE                │
│  Tabla 'lecturas' vacía                                    │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              USUARIO SELECCIONA CONTADOR                    │
└─────────────────────────────────────────────────────────────┘
                           ↓
                    ¿Tiene lectura HOY?
                    /              \
                 NO /                \ SÍ
                   ↓                  ↓
    ┌──────────────────────┐  ┌──────────────────────┐
    │ Abrir Registro       │  │ Mostrar Diálogo      │
    │ - Cámara             │  │ - Ver detalles       │
    │ - GPS                │  │ - Opción EDITAR      │
    │ - Input lectura      │  └──────────────────────┘
    └──────────────────────┘           │
                ↓                       │ (EDITAR)
    ┌──────────────────────┐           │
    │ GUARDAR LECTURA      │←──────────┘
    │ - INSERT lecturas    │
    │ - UPDATE contador    │
    │   estado='registrado'│
    └──────────────────────┘
                ↓
    ┌──────────────────────┐
    │ Confirmación         │
    │ Volver a lista       │
    └──────────────────────┘
                ↓
┌─────────────────────────────────────────────────────────────┐
│                    FIN DE PERIODO                           │
│  EXPORTAR → CSV con todas las lecturas del mes             │
└─────────────────────────────────────────────────────────────┘
```

---

## Consideraciones de Diseño

### 1. Desnormalización Intencional

La tabla `lecturas` incluye campos desnormalizados (`nombre_usuario`, `vereda`) para:
- **Optimización de reportes**: No requiere JOIN para exportar
- **Integridad histórica**: Si se modifica el nombre en `contadores`, las lecturas antiguas mantienen el nombre original
- **Simplicidad de queries**: Menos complejidad en consultas frecuentes

### 2. Validación de Fecha Estricta

El método `getLecturaPorContadorHoy()` valida **día, mes y año** exactos para evitar:
- Lecturas históricas del CSV (Diciembre 2026) sean consideradas como "de hoy"
- Problemas con cambios de mes/año
- Confusión entre periodos de facturación

### 3. Estado del Contador

El campo `estado` en `contadores` es una **caché** del estado de lectura:
- Se actualiza automáticamente al insertar/actualizar lecturas
- Permite filtrado rápido sin JOIN a `lecturas`
- Mejora rendimiento en la lista principal

### 4. Índices Estratégicos

```sql
-- Para consultas "¿Tiene lectura hoy?"
CREATE INDEX idx_lecturas_contador ON lecturas(contador_id);

-- Para reportes por periodo
CREATE INDEX idx_lecturas_fecha ON lecturas(fecha);
```

### 5. Sincronización Futura

El campo `sincronizado` en `lecturas` está preparado para:
- Sincronización con servidor backend (futuro)
- Identificar lecturas pendientes de subir
- Evitar duplicados en sincronización

---

## Formato de Datos

### Fechas (ISO 8601)
```
Almacenamiento: "2026-01-19T21:23:42.000"
Display: "19 Ene 2026" / "21:23"
```

### Coordenadas GPS
```
Almacenamiento: REAL (6 decimales)
Ejemplo: latitud = 4.123456, longitud = -73.654321
```

### Rutas de Fotos
```
Formato: "/data/user/0/com.example.app/app_flutter/photos/IMG_20260119_212342.jpg"
Relativo a: getApplicationDocumentsDirectory()
```

---

## Migración de Esquema

Actualmente en **versión 2** del esquema:

```dart
// database_service.dart
return await openDatabase(
  path, 
  version: 2,  // ← Versión actual
  onCreate: _createDB,
  onUpgrade: _onUpgrade
);
```

**Historial de versiones:**
- **v1**: Esquema inicial con campos `cedula` y `celular`
- **v2**: Eliminados campos `cedula` y `celular` (optimización de privacidad)

Para futuras migraciones, incrementar `version` y actualizar `_onUpgrade()`.

---

## Ejemplo de Uso Completo

```dart
// 1. Importar datos iniciales
final csvService = CsvImportService();
await csvService.importInitialData();

// 2. Listar contadores
final dbService = DatabaseService();
final contadores = await dbService.getContadores();

// 3. Registrar lectura
final lectura = Lectura(
  contadorId: 'PUE-102-9',
  nombreUsuario: 'Yenith Pinto',
  vereda: 'Pueblo Nuevo',
  lectura: 6350.0,
  fotoPath: '/path/to/photo.jpg',
  latitud: 4.123456,
  longitud: -73.654321,
  fecha: DateTime.now(),
  sincronizado: false,
);
await dbService.insertLectura(lectura);

// 4. Verificar estado
final lecturaHoy = await dbService.getLecturaPorContadorHoy('PUE-102-9');
if (lecturaHoy != null) {
  print('Ya registrado hoy: ${lecturaHoy.lectura}');
}

// 5. Exportar
final exportService = ExportService();
await exportService.exportarLecturas();
```

---

## Troubleshooting

### Problema: "Usuario ya registrado" aparece incorrectamente

**Causa:** Lecturas históricas del CSV insertadas en tabla `lecturas`

**Solución:** 
```dart
// En CsvImportService, NO insertar lecturas históricas:
// ❌ await _databaseService.insertLectura(lectura);
// ✅ Solo usar como referencia en contador.ultimaLectura
```

### Problema: Lecturas no se exportan

**Causa:** Tabla `lecturas` vacía

**Verificación:**
```sql
SELECT COUNT(*) FROM lecturas;
```

### Problema: Estado no se actualiza

**Causa:** Falta transacción en `insertLectura()`

**Verificación:**
```dart
// Debe incluir ambas operaciones:
await db.insert('lecturas', lectura.toMap());
await updateEstadoContador(lectura.contadorId, EstadoContador.registrado);
```

---

**Última actualización:** 2026-01-19  
**Versión del esquema:** 2  
**Autor:** Sistema AguaLector
