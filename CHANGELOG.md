## [1.2.5] - 2026-01-30

### Corregido
- **Carga de Mapas**: Se desactivó temporalmente el sistema de caché de baldosas (tiles) y se reforzaron los permisos de Internet para solucionar problemas de carga en nuevos dispositivos.

## [1.2.4] - 2026-01-30

### Mejorado
- **Diseño Flat**: Se eliminaron las sombras y elevaciones de los encabezados en toda la aplicación para una estética más limpia y minimalista.

## [1.2.3] - 2026-01-30

### Mejorado
- **Coherencia Visual**: El encabezado del mapa ahora se sombrea dinámicamente al color verde institucional al interactuar, manteniendo la consistencia con la pantalla de lista.
- **Ajuste de Clustering**: Se refinó la curva exponencial a 0.79 para un balance óptimo entre agrupación y separación.

## [1.2.2] - 2026-01-30

### Mejorado
- **Curva de Clustering**: Implementación de un radio de agrupación agresivo mediante una función de decaimiento exponencial, mejorando la separación de marcadores en niveles de zoom altos.

## [1.2.1] - 2026-01-30

### Corregido
- **Map Clustering**: Se corrigió un error de tipo en el radio dinámico de agrupación y se sincronizó el escalado del badge de notificación con el icono de gota para mantener la alineación perfecta al hacer zoom.
- **Versión**: Actualización de etiquetas a v1.2.1.

## [1.2.0] - 2026-01-30

### Optimización de Alto Rendimiento
- **Motor de Marcadores O(1):** Rediseño total de la lógica de clustering para acceso instantáneo a datos, eliminando retrasos en mapas con alta densidad de puntos.
- **UI Ultra-Fluida:** Integración de `ValueNotifiers` para desacoplar el movimiento del mapa (zoom/rotación) del ciclo de vida del widget principal, logrando 60fps constantes.
- **Optimización de Mapas de Alto Rendimiento**: Implementación de lógica de clustering $O(1)$ y desacoplamiento de estado con `ValueNotifiers` (60fps garantizados).
- **Clustering Dinámico**: El radio de agrupamiento ahora se ajusta automáticamente según el nivel de zoom (inversamente proporcional).
- **Escalado Unificado**: Los marcadores individuales y los grupos crecen y se encogen a la misma velocidad durante el zoom.
- **Corrección de Bugs Visuales**:
    - Solucionado el problema de recorte (clipping) de iconos en zoom máximo.
    - Sincronización del desplazamiento de la sombra con el tamaño del icono.

## [1.1.0] - 2026-01-30

### Sistema de Mapa Premium
- **Clustering Estilizado:** Implementación de grupos de marcadores con forma de gota de agua y badges de progreso dinámicos.
- **Verticalidad Total:** Se corrigió la orientación de todos los iconos (marcadores y grupos) para que permanezcan siempre verticales sin importar la rotación del mapa.
- **Persistencia de Cámara:** El mapa ahora recuerda automáticamente la última ubicación, nivel de zoom y rotación del usuario al navegar entre pantallas.
- **Optimización Estética:** Reducción del radio de agrupación a 30px y ajuste del tamaño de marcadores para una visualización más limpia.
- **Pantalla de Carga:** Nueva transición fluida con el logo corporativo al cargar los datos del mapa.
- **Caché de Mapas:** Implementación de caché en memoria para los mosaicos (tiles), reduciendo el parpadeo blanco al navegar.

## [1.0.3] - 2026-01-30

### Corregido
- **Exportación CSV:** Se corrigió el comportamiento de la exportación "Solo reporte CSV". Ahora el archivo se comparte directamente en formato `.csv` sin ser comprimido en un archivo ZIP, facilitando su visualización inmediata en dispositivos móviles.

## [1.0.2] - 2026-01-21

### Bug Fixes
- **Splash Nativo (Xiaomi/Dark Mode):** Se corrigió un error crítico donde el fondo del splash se veía negro en dispositivos con modo oscuro activo (especialmente Xiaomi/HyperOS). Se implementó un bloqueo de inversión de color y se sincronizó el tamaño del logo (108dp) para una transición 1:1 con la interfaz de Flutter.

## [1.0.1] - 2026-01-21

### Mejoras de Producción
- **Renombramiento:** La aplicación ahora se llama **GuapoLector**.
- **Ícono Oficial:** Se ha actualizado el ícono de la aplicación con el logo de Asoguapo.
- **Splash Nativo:** Se integró `flutter_native_splash` para eliminar el parpadeo negro al iniciar la aplicación.

## [1.0.0] - 2026-01-21

### Lanzamiento Oficial
- **Nuevo Logo:** Se integra la imagen corporativa oficial de Asoguapo (gota sonriente).
- **Pantalla de Carga:** Se añade una pantalla de inicio (Splash Screen) animada y armoniosa.
- **Estabilidad:** Versión estable para producción.

## [0.9.10] - 2026-01-21

### Bug Fixes
- **Lecturas Nulas - Migración DB v4:** Se corrigió la excepción `SQLITE_CONSTRAINT_NOTNULL` que impedía guardar lecturas sin valor numérico. Se modificó el esquema de la base de datos (versión 4) para permitir valores `NULL` en la columna `lectura`, preservando así la distinción entre "contador en 0" y "no se pudo leer". La migración es automática y preserva todos los datos existentes.

## [0.9.9] - 2026-01-20

### Mejoras de UX
- **Detalle Histórico:** Ahora es posible tocar cualquier lectura en la pantalla de "Historial" para ver todos los detalles (foto grande, ubicación GPS, comentarios, fecha exacta) en una ventana emergente.

## [0.9.8] - 2026-01-20

### Rendimiento
- **Optimización de Teclado:** Se implementó una pausa automática del feed de la cámara al abrir diálogos de entrada de texto. Esto elimina el "lag" severo que ocurría al desplegar el teclado mientras la cámara estaba activa, sin sacrificar la calidad de la imagen (se mantiene en resolución máxima).

## [0.9.7] - 2026-01-20

### Bug Fixes
- **Visualización de Input Deshabilitado:** Se corrigió un error donde el campo de lectura permanecía con fondo blanco al bloquearse. Ahora respeta correctamente el estado gris cuando se ha ingresado un motivo de no lectura.

## [0.9.6] - 2026-01-20

### UI Tweaks
- **Mejora Espaciado en Diálogo:** Se aumentó la separación entre el botón de "Borrar Motivo" y "Aceptar" en el diálogo de anomalías para prevenir pulsaciones accidentales y mejorar la estética.

## [0.9.5] - 2026-01-20

### UX Polishing
- **Mejora en Diálogo de Anomalía:** Se reemplazó el botón "Volver" por un ícono de cierre 'X' y se mejoró el diseño del botón "Borrar Motivo".
- **Feedback Visual:** Ahora el campo de lectura se torna gris (deshabilitado) visualmente cuando se ha registrado un motivo de no lectura, indicando claramente al usuario que no se ingresará un valor numérico.

## [0.9.4] - 2026-01-20

### Funcionalidad y Datos
- **Lecturas Nulas:** Ahora el sistema soporta guardar registros con valor de lectura `nulo` (vacío) en lugar de `0` cuando se reporta una anomalía. Esto se refleja como una celda vacía en el CSV y "Sin lectura" en la interfaz.
- **UI Diálogo Anomalía:** Se actualizó el diálogo "¿Por qué no se puede leer?" para tener botones estilizados (Volver/Borrar) y limpiar automáticamente el campo de lectura numérica al aceptar una justificación.

## [0.9.3] - 2026-01-20

### UX y Conectividad
- **GPS Tolerante a Fallos:** Se implementó un tiempo de espera de 6 segundos para la obtención de coordenadas. Si excede este tiempo (zonas techadas o rurales profundas), el sistema habilita el guardado en modo "Sin GPS" (indicador amarillo) para no detener la operación.

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
