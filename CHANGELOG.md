# Changelog

Todas las versiones importantes y cambios realizados en el proyecto AguaLector.

## [0.9.2] - 2026-01-20

### Mejoras de UI/UX
- **Unificación de Diseño:** La caja de "Lectura Registrada" ahora tiene el mismo estilo premium que la pantalla de confirmación exitosa.
- **Visualización Completa:** El diálogo de revisión ahora incluye la fotografía capturada y la ubicación GPS para una verificación rápida.
- **Optimización de Código:** Se eliminaron redundancias mediante la creación de un widget reutilizable `InfoLecturaWidget`, mejorando la mantenibilidad del proyecto.

## [0.9.1] - 2026-01-20

### Cambios
- **Seguridad y Auditoría:** Se ha hecho obligatorio tomar una fotografía para todos los registros, incluso si el contador no es legible. Esto garantiza una evidencia visual en cada visita.
- **UI/UX:** Se añadió la visualización de la ubicación GPS en el diálogo de revisión de lecturas existentes en la pantalla principal.

## [0.9.0] - 2026-01-20

### Añadido
- **Reporte de Anomalías:** Nueva opción "No se puede leer el contador" que permite registrar motivos descriptivos (ej: medidor roto, acceso denegado).
- **Esquema de Datos:** Se añadió el campo `comentario` a la base de datos y a los reportes CSV.
- **Documentación:** Renovación completa del `README.md` y actualización del Manual Técnico con la nueva hoja de ruta.

## [0.8.0] - 2026-01-20

### LANZAMIENTO: PILOTO FASE 2
- **Despliegue Total:** Transición oficial a la segunda fase del piloto, habilitando la carga de todos los contadores de la comunidad.
- **Estabilidad:** Consolidación de una versión pulida y estable tras las correcciones de UI y optimización de exportación.
- **Hoja de Ruta:** Se definieron los objetivos futuros en el Manual Técnico (Ordenamiento inteligente y Herramienta de PC).

## [0.7.4] - 2026-01-20

### Mejorado
- **Control de Exportación:** Se bloquea el botón de exportación mientras un proceso está en curso para evitar ejecuciones duplicadas.
- **Opción de Cancelación:** Si la exportación (compresión) tarda más de 5 segundos, aparece automáticamente una opción para cancelar el proceso.

## [0.7.3] - 2026-01-20

### Cambios
- **Simplificación de UI:** Se eliminaron las etiquetas de "Sin referencia" y cálculos de consumo en la pantalla de historial para ofrecer una vista más limpia y directa.
- **Optimización de Exportación:** Se simplificó el reporte CSV eliminando textos descriptivos como "sin referencia", dejando las celdas vacías para un reporte más profesional y menos saturado.

## [0.7.2] - 2026-01-20

### Mejorado
- **Control de Consumo:** Se implementó la lógica de "Sin referencia" para casos donde no existe una lectura previa en el mes anterior.
- **Visualización en Historial:** Ahora las tarjetas del historial muestran el consumo calculado (+X m³) o el estado "Sin referencia" de forma visual.
- **Exportación CSV:** Se corrigió el cálculo de consumo en el reporte exportado para evitar valores erróneos cuando no hay lectura anterior, exportando "sin referencia" en su lugar.

## [0.7.1] - 2026-01-20

### Cambios
- **Unificación de Color:** Se revirtió el esquema de color a un verde esmeralda uniforme (Color Primario) en toda la aplicación, eliminando el uso del color secundario en estados de éxito e indicadores para mantener una estética monocromática coherente.

## [0.7.0] - 2026-01-20

### Mejorado
- **Identidad Visual:** Se implementó el color secundario (azul) para representar estados de éxito y registros completados, diferenciándolos de las acciones primarias (verde).
- **UI Historial:** El valor de consumo (m³) ahora resalta en color secundario para una lectura más rápida.
- **Diálogo de Registro Existente:** Rediseño completo de la alerta "Lectura en periodo activo" con una estética más profesional, mejor jerarquía de información y acciones claras.

## [0.6.2] - 2026-01-20

### Mejorado
- **Buscador Inteligente:** El buscador de la lista principal ahora ignora tildes y diéresis (ej. busca "Sandoval" y encuentra "SANDOVAL").
- **Búsqueda por Fragmentos:** Permite buscar por partes del nombre o código (ej. "Juan 102" encontrará registros que contengan ambos términos en cualquier orden).

## [0.6.1] - 2026-01-20

### Corregido
- **Validación de Exportación:** El botón "EXPORTAR DATOS" en el historial ahora se deshabilita automáticamente (se pone gris) si no hay registros presentes para la vereda seleccionada, evitando intentos de exportación vacíos.

## [0.6.0] - 2026-01-20

### Cambios
- **Ajuste de UI en Tarjetas:** Se movió el código del contador a la parte inferior derecha de la tarjeta y se eliminó el símbolo `#`. Esto permite nombres de usuario más largos sin recortes visuales y mantiene la identificación de forma sutil.

## [0.5.9] - 2026-01-20

### Agregado
- **Feedback Detallado de Exportación:** Nuevo sistema de progreso que calcula el tamaño total de las evidencias (MB) y estima el tiempo restante para grandes volúmenes de datos (ej. 500 fotos).
- **Fases de Exportación:** Visualización clara de las etapas: Cálculo de tamaño, Empaquetado de fotos y Compresión final.

## [0.5.8] - 2026-01-20

### Cambios
- **Exportación Total Restaurada:** Se habilitó nuevamente la opción de exportar "Todas" las veredas simultáneamente desde el historial, permitiendo obtener un reporte consolidado global en un solo archivo ZIP.

## [0.5.7] - 2026-01-20

### Agregado
- **Feedback Visual de Scroll:** Implementación de un scrollbar (slider verde) sutil que solo aparece al mover la lista, con fondo transparente para una interfaz más limpia.
- **Identificación de Medidores:** Se agregó el código del contador (`ID`) en cada tarjeta de usuario de forma estética y discreta ("oculto a simple vista").
- **Base de Datos Completa:** Se actualizó el importador para soportar el nuevo formato de reporte de usuarios completos, permitiendo la carga total de la base de datos de ASOGUAPO.

## [0.5.6] - 2026-01-20

### Corregido
- **Precisión de GPS en Fotos:** Se corrigió un bug donde múltiples fotos podían quedar con la misma ubicación. Ahora el sistema prioriza una ubicación fresca y se refresca automáticamente al reintentar una fotografía.

## [0.5.5] - 2026-01-20

### Agregado
- **Ventana de Edición de 15 Días:** Ahora las lecturas pueden borrarse o corregirse hasta 15 días después de su registro.
- **Auto-Limpieza de Evidencias:** Pasados los 15 días, las fotos se borran automáticamente del dispositivo para liberar espacio.

### Cambios
- **Ciclo Mensual Automático:** Tras el periodo de 15 días, el contador vuelve automáticamente a estado "Pendiente" y toma la lectura anterior como base para el nuevo mes.

## [0.5.4] - 2026-01-20

### Agregado
- **Exportación en Segundo Plano (Isolates):** Se movió el proceso de compresión ZIP a un hilo separado para evitar que la interfaz se congele.
- **Barra de Progreso Detallada:** Nueva pantalla de carga que muestra el porcentaje real de avance durante el empaquetado de archivos.
- **Sincronización de Filtros:** La vereda seleccionada ahora se mantiene sincronizada entre la lista principal y el historial.

### Cambios
- **Unificación de Archivos (ZIP Maestro):** Para evitar fallos al compartir por WhatsApp, ahora todas las exportaciones generan un único archivo ZIP (incluyendo el CSV en su interior).

### Corregido
- **Bug de Envío de Archivos:** Solución definitiva al problema donde WhatsApp no adjuntaba archivos al compartir.
- **Fluidez del Sistema:** Eliminación de bloqueos visuales al procesar grandes cantidades de fotos.

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
