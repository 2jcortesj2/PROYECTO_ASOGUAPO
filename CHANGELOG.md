# Changelog

Todas las versiones importantes y cambios realizados en el proyecto AguaLector.

## [0.5.3] - 2026-01-20

### Corregido
- **Exportación en WhatsApp:** Se corrigió un error donde algunos dispositivos (como al compartir por WhatsApp) solo enviaban el texto pero no los archivos adjuntos. Se implementaron tipos MIME explícitos y limpieza de buffer para asegurar la entrega de archivos.

## [0.5.2] - 2026-01-20

### Agregado
- **Menú de Exportación Seleccionable:** Ahora al presionar "Exportar Datos" se despliega un menú con 3 opciones:
    1. **Solo reporte CSV**: Solo el archivo de datos.
    2. **Solo fotos (ZIP)**: Solo las fotos comprimidas.
    3. **Exportar TODO**: Ambos archivos (CSV y ZIP) al mismo tiempo.
- **Optimización para Baja Gama:** Se implementó `cacheWidth` en la visualización de fotos del historial para reducir el consumo de memoria RAM al decodificar imágenes.
- **Gestión de Temporales:** La exportación ahora utiliza el directorio de cache (`getTemporaryDirectory`), optimizando el almacenamiento interno y permitiendo que el SO limpie los archivos cuando sea necesario.

### Cambios
- **Restricción de Exportación:** Se eliminó la opción de exportar "Todas" las veredas simultáneamente. Ahora es obligatorio filtrar por una vereda específica para exportar, mejorando la estabilidad del sistema.
- **Formato CSV:** Se utiliza punto y coma (`;`) como separador estándar. Se eliminó el BOM para esta versión para asegurar compatibilidad con visores ligeros.

## [0.5.1] - 2026-01-20

### Agregado
- **Exportación de Imágenes (ZIP):** Generación automática de archivo ZIP con las fotos de los medidores.
- **Multi-Compartir:** Compartir simultáneamente CSV y ZIP.

### Corregido
- **Nombres de Archivos:** Mejora en la nomenclatura de archivos exportados.

## [0.5.0] - 2026-01-20

### Agregado
- **Filtros por Vereda en Historial:** Reemplazados los filtros temporales por filtros geográficos.
- **Miniaturas Reales:** Visualización de la foto real capturada en la lista del historial.
- **Exportación Inteligente:** Inclusión de códigos de vereda en nombres de archivos.
- **Gestión de Lecturas:** Implementación de eliminación individual de registros con confirmación.
- **Ocultar Completados:** Filtro para ver solo medidores pendientes en la lista principal.

## [0.4.1] - 2026-01-19

### Cambios
- **Etiqueta en Tarjeta:** Actualizada la etiqueta del contador para mayor claridad.
- **Navegación:** Mejora en la persistencia del estado al navegar entre pantallas.

## [0.4.0] - 2026-01-18

### Agregado
- **Persistencia SQLite:** Integración completa de base de datos local para contadores y lecturas.
- **Carga Inicial:** Importación automática de datos desde CSV piloto.

## [0.3.0] - 2026-01-12

### Agregado
- **Cámara Embebida:** Captura de fotos integrada directamente en la pantalla de registro.
- **GPS Real:** Obtención de coordenadas geográficas mediante geolocator.
- **Gestión de Permisos:** Sistema de solicitud de permisos al inicio.

## [0.2.0] - 2026-01-10

### Agregado
- Estructura base de la aplicación con Flutter Material Design.
- Gestión inicial de temas y constantes.

## [0.1.0] - 2026-01-05

### Agregado
- Estructura inicial del proyecto.
- Configuración de Git con flujo de trabajo de dos ramas.
