# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Versionado Semántico](https://semver.org/lang/es/).

## [Sin Lanzamiento]

### Agregado
- Documento de diseño UI/UX para MVP
- Mockups visuales de las 4 pantallas principales
- Estructura inicial del proyecto
- Configuración de Git con flujo de trabajo de dos ramas

## [0.5.2] - 2026-01-20

### Agregado
- **Optimización para Baja Gama:** Se implementó `cacheWidth` en la visualización de fotos del historial para reducir el consumo de memoria RAM al decodificar imágenes.
- **Gestión de Temporales:** La exportación ahora utiliza el directorio de cache (`getTemporaryDirectory`) para generar archivos ZIP y CSV, permitiendo que el sistema operativo limpie estos archivos automáticamente.

### Cambios
- **Restricción de Exportación:** Se eliminó la opción de exportar "Todas" las veredas simultáneamente. Ahora es obligatorio filtrar por una vereda específica (REC, PUE, TEN) para exportar, protegiendo la estabilidad en dispositivos con recursos limitados.
- **Limpieza de Exportación:** Se eliminó el marcador BOM del CSV para simplificar la generación de archivos, manteniendo el soporte estándar de UTF-8.

## [0.5.1] - 2026-01-20

### Agregado
- **Exportación de Imágenes (ZIP):** Ahora al exportar datos, se genera automáticamente un archivo ZIP con todas las fotos de los medidores correspondientes al filtro seleccionado.
- **Multi-Compartir:** El botón de exportar ahora comparte simultáneamente el archivo CSV de datos y el archivo ZIP de fotos.

### Corregido
- **Compatibilidad con Excel:** Se implementó el uso de punto y coma (`;`) como separador y la codificación UTF-8 con BOM para asegurar que las tildes y caracteres especiales se vean correctamente en Excel.
- **Nombres de Archivos:** Mejora en la nomenclatura de archivos exportados e imágenes dentro del ZIP.

## [0.5.0] - 2026-01-20

### Agregado
- **Filtros por Vereda en Historial:** Reemplazados los filtros temporales (Hoy/Semana/Mes) por filtros geográficos (Todas, El Recreo, Pueblo Nuevo, El Tendido).
- **Miniaturas Reales:** El historial ahora muestra la foto real capturada para cada lectura en lugar de un icono genérico.
- **Exportación Inteligente:** 
  - El nombre del archivo CSV ahora incluye el código de la vereda exportada (`REC`, `PUE`, `TEN` o `ALL`).
  - Posibilidad de exportar solo las lecturas filtradas actualmente en pantalla.

### Cambios
- **Refinamiento UI Pantalla Confirmación:** 
  - Fecha y hora ahora se muestran por separado.
  - El botón "Siguiente Contador" fue eliminado para simplificar el flujo.
  - El botón "Volver a la Lista" ahora usa el estilo primario (azul/verde) para mayor claridad.
- **Limpieza de UI en Registro:** Eliminada la notificación de "Foto capturada exitosamente" para un flujo más rápido.

## [0.4.1] - 2026-01-20

### Corregido
- **Lógica de Piloto:** Las lecturas importadas del 20 de Dic se toman como "Lectura Anterior". Los usuarios inician en estado **PENDIENTE** para la lectura de Enero.
- **Validación de Fecha:** Verificación estricta (día/mes/año) para "Lectura Existente" hoy.

### Cambios
- **UI del Diálogo:** Rediseño completo del diálogo "Lectura registrada hoy":
  - Título más claro y directo.
  - Eliminación de barras divisorias y carteles para un diseño más limpio.
  - Estilo visual consistente con la pantalla de confirmación.
- **Notificaciones:** Eliminada la notificación intrusiva al capturar fotos.
- **Etiquetas Claras:** En las tarjetas de contadores se muestra "Lectura mes anterior: XXX m³" para evitar confusiones.
- **CSV Headers:** Renombrados a `HISTORICO_NOV`, `HISTORICO_DIC`, `FECHA_HISTORICO_DIC` para mayor claridad.
- **Optimización:** Eliminación de campos no utilizados (`Cedula`, `Celular`) para privacidad y ligereza.

## [0.4.0] - 2026-01-19

### Agregado
- **Persistencia de Datos:** Implementación de base de datos SQLite (`sqflite`) para almacenar usuarios y lecturas localmente.
- **Importación de Datos:** Carga automática de `LECTURAS_PILOTO.csv` al iniciar la aplicación.
- **Gestión de Lecturas Existentes:** Lógica en `ListaContadoresScreen` para detectar usuarios con lecturas del día y ofrecer edición.
- **Exportación Real:** Generación de archivo CSV con `ExportService` y funcionalidad de compartir.
- **Modo Edición:** `RegistroLecturaScreen` ahora permite actualizar lecturas existentes.

### Cambios
- `ListaContadoresScreen`: Ahora consume datos reales de la base de datos en lugar de lista estática.
- `HistorialScreen`: Conectado a la base de datos para mostrar historial real y permitir exportación.
- `main.dart`: Inicializa base de datos e importa datos del piloto antes de ejecutar la app.
- **Optimización de Datos:** Eliminados los campos `Cédula` y `Celular` del modelo y base de datos.

---

## [0.3.1] - 2026-01-19

### Agregado
- **Selector de Veredas:** Nuevo selector dinámico en la pantalla principal para filtrar contadores.
- **Botón de Exportar:** Acceso directo en la pantalla principal (posicionado bajo el de historial).

### Cambios
- **Refactorización de Terminología:** Se reemplazó "Sector" por **"Vereda"** en toda la aplicación (modelos, pantallas y documentación).
- **Datos Reales:** Actualización de datos de ejemplo con las veredas: "El Recreo", "El Tendido" y "Pueblo Nuevo".
- **Interfaz:** Mejora en el diseño de los botones flotantes (FABs) para mayor claridad.

---

## [0.3.0] - 2026-01-19

### Agregado
- **Permisos al inicio:** La aplicación solicita permisos de cámara y GPS al abrir.
- **Cámara embebida:** Vista previa en vivo usando el paquete `camera` en lugar de cámara externa.
- **Servicio de permisos:** Nuevo `permission_service.dart` para manejo centralizado.
- **Widget de cámara:** Nuevo `camera_preview_widget.dart` con componentes reutilizables.
- **Pantalla de permisos:** UI amigable cuando se deniegan permisos críticos.

### Cambios
- `main.dart`: Solicita todos los permisos antes de iniciar la app.
- `camera_service.dart`: Refactorizado para usar el paquete `camera` con `CameraController`.
- `registro_lectura_screen.dart`: Muestra vista previa de cámara en vivo.
- `pubspec.yaml`: Reemplazado `image_picker` por `camera: ^0.11.0+2`.

### Optimizaciones para Baja Gama
- Resolución de cámara baja por defecto (`ResolutionPreset.low`).
- Audio deshabilitado en cámara (`enableAudio: false`).
- GPS prioriza última ubicación conocida para respuesta rápida.
- Uso de `RepaintBoundary` en widgets de cámara.
- Manejo de ciclo de vida para liberar recursos.

---

## [0.2.0] - 2026-01-19

### Agregado
- **Captura de foto real:** Integración con `image_picker` para usar la cámara del dispositivo.
- **GPS real:** Integración con `geolocator` para obtener coordenadas de ubicación.
- **Servicios:** Nueva capa de servicios (`camera_service.dart`, `gps_service.dart`).
- **Permisos Android:** Configuración de permisos de cámara, ubicación y almacenamiento.
- **Manejo de errores:** Feedback visual para errores de GPS y cámara.

### Cambios
- `registro_lectura_screen.dart`: Ahora usa servicios reales en lugar de simulaciones.
- `AndroidManifest.xml`: Permisos agregados para cámara y GPS.
- `pubspec.yaml`: Nuevas dependencias (`image_picker`, `geolocator`, `permission_handler`, `path_provider`).

---

## [0.1.0] - 2026-01-19

### Agregado
- **Prototipo UI Flutter completo:** Implementación de las 4 pantallas principales.
- **Sistema de Temas:** Configuración de Material 3 con alto contraste para exteriores.
- **Modelos de Datos:** Definición de clases `Contador` y `Lectura` con serialización.
- **Navegación:** Flujo completo entre lista, registro, confirmación e historial.
- **Widgets Personalizados:** `BotonPrincipal`, `ContadorCard`, `LecturaInput` y `GpsIndicator`.
- **Documentación:** Manual de usuario, manual técnico y **guía de testing**.
- **Estructura Git:** Configuración de ramas `main`/`dev` y flujo de trabajo simplificado.

### Corregido
- **Pruebas:** Corregida referencia a `AguaLectorApp` en `widget_test.dart` y añadidos escenarios reales.
- **Mantenimiento:** Migrados métodos obsoletos (`withOpacity` -> `withValues`) para compatibilidad con Flutter 3.27+.
- **Tema:** Eliminados parámetros de color obsoletos en `ColorScheme`.
- **Documentación:** Corregidos comentarios dangling en archivo de constantes.

### Planeado para Fase 4
- Implementación de persistencia local con SQFLite.
- Lógica de exportación de archivos CSV reales.
- **Gestión de Usuarios Existentes:** Al seleccionar un usuario con datos completos, mostrar la información recolectada y preguntar si se desea editar el perfil.

---
