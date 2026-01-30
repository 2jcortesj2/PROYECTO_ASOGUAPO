# Documentación Técnica - AguaLector

## 1. Base de Datos (SQLite)

La aplicación utiliza `sqflite` para la persistencia local. La base de datos se llama `agualector.db`.

### 1.1 Esquema de Tablas

#### Tabla `contadores`
Almacena la información estática y el estado actual de cada suscriptor.

| Columna                | Tipo      | Descripción                                           |
| :--------------------- | :-------- | :---------------------------------------------------- |
| `id`                   | TEXT (PK) | Código concatenado único (ej. `TEN-201-1`).           |
| `nombre`               | TEXT      | Nombre del suscriptor.                                |
| `vereda`               | TEXT      | Vereda a la que pertenece.                            |
| `lote`                 | TEXT      | Información adicional de ubicación (opcional).        |
| `ultima_lectura`       | REAL      | Lectura del mes anterior (base para el cálculo).      |
| `fecha_ultima_lectura` | TEXT      | Fecha de la lectura anterior.                         |
| `estado`               | TEXT      | Estado actual: `pendiente`, `registrado`, `conError`. |
| `latitud`              | REAL      | Coordenada GPS (Latitud). **[Nuevo en v0.5.x]**       |
| `longitud`             | REAL      | Coordenada GPS (Longitud). **[Nuevo en v0.5.x]**      |

#### Tabla `lecturas`
Registra las lecturas tomadas en el ciclo actual.

| Columna          | Tipo         | Descripción                            |
| :--------------- | :----------- | :------------------------------------- |
| `id`             | INTEGER (PK) | Autoincremental.                       |
| `contador_id`    | TEXT (FK)    | Relación con `contadores(id)`.         |
| `nombre_usuario` | TEXT         | Copia del nombre para histórico.       |
| `vereda`         | TEXT         | Copia de la vereda.                    |
| `lectura`        | REAL         | Valor de la lectura actual (m³).       |
| `foto_path`      | TEXT         | Ruta local de la foto de evidencia.    |
| `latitud`        | REAL         | GPS donde se tomó la lectura.          |
| `longitud`       | REAL         | GPS donde se tomó la lectura.          |
| `fecha`          | TEXT         | Timestamp de la toma.                  |
| `sincronizado`   | INTEGER      | Flag (0/1) para sincronización futura. |
| `comentario`     | TEXT         | Observaciones adicionales.             |

### 1.2 Migraciones (`onUpgrade`)
El sistema maneja versiones de base de datos para evoluciones seguras.
- **Versión 4 a 5**: Se agregaron las columnas `latitud` y `longitud` a la tabla `contadores` para soportar el mapa.

---

## 2. Sistema de Mapa

El módulo de mapas permite visualizar la ubicación de los contadores y su estado de lectura en tiempo real.

### 2.1 Arquitectura
- **Librería**: `flutter_map` con `latlong2`.
- **Proveedor de Mapas**: OpenStreetMap (TileLayer).
- **Servicios**:
    - `MapService`: Capa de abstracción para lógica de mapas. Consume `DatabaseService` para obtener datos reales.
    - `DatabaseService`: Provee los datos crudos desde SQLite.

### 2.2 Flujo de Datos
1.  `MapScreen` solicita datos a `MapService.getContadoresConUbicacion()`.
2.  `MapService` consulta la DB filtrando contadores que tengan `latitud` y `longitud` NO nulos.
3.  El mapa renderiza marcadores en esas coordenadas.

### 2.3 Lógica de Marcadores
Los marcadores cambian visualmente según el campo `estado` del contador:

- **🟢 Verde (Registrado)**: El contador ya tiene lectura en el ciclo actual.
    - Icono: `Icons.check_circle` (en detalle) / Gota blanca con fondo verde.
    - Borde: Blanco.
- **🔘 Gris/Naranja (Pendiente)**: Falta tomar la lectura.
    - Icono: `Icons.water_drop` (en detalle) / Gota gris con fondo claro.
    - Borde: Rojo (para resaltar pendientes).

### 2.4 Interacción (Bottom Sheet)
Al tocar un marcador, se abre un `DraggableScrollableSheet` que valida en tiempo real si existe una lectura para ese contador (`DatabaseService.getLecturaActiva`):

- **Si está Pendiente**:
    - Muestra "Lectura Pendiente".
    - Muestra la última lectura registrada (mes anterior).
    - Botón **"REGISTRAR LECTURA"**: Navega a `RegistroLecturaScreen`.
- **Si está Registrado**:
    - Muestra "Lectura Registrada".
    - Muestra resumen (Consumo, Fecha).
    - Botón **"VER / EDITAR"**: Permite corregir la lectura existente.

### 2.5 Importación de Coordenadas (CSV)
Para asociar coordenadas a los contadores existentes sin perder sus lecturas:
1.  El sistema busca `assets/LECTURAS_TEN_20260126_1622.csv`.
2.  Lee las columnas `LATITUD` y `LONGITUD`.
3.  Usa `DatabaseService.updateContadorUbicacion(id, lat, lng)` para actualizar **solo** las coordenadas del contador, preservando su estado (`pendiente`/`registrado`) y sus lecturas históricas.
