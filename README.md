# GuapoLector 💧 v1.0.1

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)](https://dart.dev/)
[![SQLite](https://img.shields.io/badge/SQLite-3.x-green.svg)](https://sqlite.org/)
[![Platform](https://img.shields.io/badge/Platform-Android-orange.svg)](https://android.com/)

**AguaLector** es una solución móvil diseñada específicamente para la gestión eficiente del registro de lecturas de contadores de agua potable en comunidades rurales y administraciones locales de acueducto (ASOGUAPO).

## 🚀 Misión del Proyecto
Digitalizar y agilizar el proceso de toma de lecturas en campo, eliminando el uso de papel, reduciendo errores humanos y garantizando la trazabilidad mediante pruebas fotográficas y geolocalización.

---

## 🎯 Estado Actual: Piloto Fase 2 - Despliegue Total (v0.9.0)

Esta versión consolida la madurez de la aplicación tras múltiples ciclos de retroalimentación, habilitando el despliegue para la totalidad de suscriptores y añadiendo flexibilidad para casos excepcionales de lectura.

### ✨ Características Principales

- 📱 **Gestión Segmentada:** Listado de contadores organizado por zonas geográficas (Veredas: El Recreo, Pueblo Nuevo, El Tendido).
- 📸 **Evidencia Fotográfica:** Cámara embebida de baja resolución optimizada para no saturar el almacenamiento, pero garantizando la legibilidad de la lectura.
- 📍 **Auditoría GPS:** Registro automático de coordenadas exactas (6 decimales) en cada toma de lectura.
- 🔢 **Validación Inteligente:** Sistema de alertas para consumos atípicos y ventana de edición protegida de 15 días.
- ⚠️ **Gestión de Excepciones:** Opción discreta para registrar motivos por los cuales no se pudo realizar una lectura (contador roto, acceso denegado, etc.).
- 💾 **Persistencia Robusta:** Base de Datos SQLite local que permite trabajar sin conexión a internet.
- 📤 **Exportación Profesional:** Generación de reportes unificados en CSV y paquetes de fotos en ZIP, compartibles directamente vía WhatsApp o correo.

---

## 🛠️ Stack Tecnológico

| Componente     | Tecnología                 |
| :------------- | :------------------------- |
| **Framework**  | Flutter 3.x                |
| **Lenguaje**   | Dart                       |
| **BBDD Local** | SQLite (sqflite)           |
| **Cámara**     | camera (Isolate optimized) |
| **GPS**        | geolocator (High Accuracy) |
| **Compresión** | archive (compute isolate)  |

---

## 💻 Instalación y Configuración

### Prerrequisitos
- Flutter SDK instalado.
- Android SDK (API 24 o superior).
- Dispositivo Android físico para pruebas de Cámara y GPS.

### Clonación y Despliegue
```bash
git clone https://github.com/2jcortesj2/PROYECTO_ASOGUAPO.git
cd PROYECTO_ASOGUAPO
cd app
flutter pub get
flutter run --release
```

---

## 📁 Estructura de Documentación

Para una comprensión profunda del sistema, consulta los siguientes manuales en la carpeta `/docs`:

1. 📖 **[Manual de Usuario](docs/manual_usuario.md):** Guía paso a paso para los lectores en campo.
2. 🛠️ **[Manual Técnico](docs/manual_tecnico.md):** Arquitectura, esquema de BD y lógica de negocio.
3. 🧪 **[Guía de Testing](docs/TESTING.md):** Casos de prueba y validaciones.

---

## 📋 Flujo de Exportación/Importación

1. **Importación:** La app carga automáticamente los usuarios desde `assets/LECTURAS_PILOTO.csv` en el primer inicio.
2. **Toma de datos:** El lector registra lecturas o reporta anomalías.
3. **Cierre:** Se exporta el ZIP desde la pantalla de Historial.
4. **Procesamiento:** El reporte CSV incluye columnas de Lectura Anterior, Actual, Consumo, Coordenadas y Motivos de No Lectura.

---

## 🏷️ Versiones Relevantes
- **v0.5.x:** Implementación de compresión ZIP en hilos separados (Isolates).
- **v0.7.x:** Refinamiento visual, scrollbars personalizados y unificación de colores (Verde ASOGUAPO).
- **v0.8.0:** Despliegue total del padrón de usuarios.
- **v0.9.0:** Introducción de registro de comentarios para lecturas fallidas.

---

## 📄 Licencia y Autoria
Desarrollado para la **Asociación de Suscriptores de Acueducto (ASOGUAPO)**. Uso restringido para la administración comunal.

---
*AguaLector: Transparencia y eficiencia en cada gota.*