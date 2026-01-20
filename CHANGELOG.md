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
