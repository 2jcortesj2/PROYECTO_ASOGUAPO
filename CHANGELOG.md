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

### Planeado para Fase 3
- Implementación de persistencia local con SQFLite.
- Integración de cámara nativa y captura de coordenadas GPS reales.
- Lógica de exportación de archivos CSV reales.
