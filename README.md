# AguaLector 💧 v0.5.1

Aplicación móvil Android para registro de lecturas de contadores de agua potable en comunidades rurales.

## 🎯 Estado Actual: Fase 5 - Organización de UI y Exportación Pulida (v0.5.1)

Esta versión se enfoca en la exportación masiva de datos y fotos, asegurando la compatibilidad con Excel y facilitando la gestión de evidencias visuales mediante archivos comprimidos ZIP.

## ✨ Características Principales

- 📋 Lista de contadores organizada por veredas (REC, PUE, TEN)
- 📷 Captura de foto con cámara en vivo (embebida)
- 🔢 Registro manual de lectura con validación de historial
- 📍 Geolocalización automática (GPS) con 6 decimales de precisión
- 📅 Marca de tiempo automática y formateada
- 💾 Almacenamiento local persistente (SQLite)
- 📤 Exportación inteligente a CSV (Semicolón + UTF-8 BOM)
- 📦 Exportación de fotos en formato ZIP
- 🧹 Gestión de lecturas (edición y eliminación individual)
- 🌓 Soporte para visualización selectiva (ocultar completados)
- 🔄 Compartir varios archivos a la vez (CSV + ZIP)

## 🛠️ Tecnologías

- **Framework:** Flutter 3.x
- **Lenguaje:** Dart
- **Base de datos:** SQLite (sqflite)
- **Cámara:** camera (embebida)
- **GPS:** geolocator
- **Exportación:** csv, share_plus

## 📁 Estructura del Proyecto

```
PROYECTO_ASOGUAPO/
├── app/                    # Código Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/         # Tema, constantes
│   │   ├── models/         # Modelos de datos
│   │   ├── screens/        # Pantallas
│   │   ├── widgets/        # Componentes reutilizables
│   │   ├── services/       # Lógica de negocio
│   │   └── utils/          # Utilidades
│   └── pubspec.yaml
├── docs/                   # Documentación
│   ├── manual_usuario.md
│   ├── manual_tecnico.md
│   └── TESTING.md          # Guía de pruebas
├── .gitignore
├── CHANGELOG.md
└── README.md
```

## 🧪 Pruebas

El proyecto incluye una guía de testing detallada en [docs/TESTING.md](docs/TESTING.md) que cubre análisis estático y casos de prueba manuales.

Para ejecutar pruebas automáticas:
```bash
cd app
flutter test
```

## 🚀 Instalación

### Prerrequisitos

- Flutter SDK 3.x
- Android Studio / VS Code
- Dispositivo Android o emulador

### Pasos

```bash
# Clonar repositorio
git clone https://github.com/2jcortesj2/PROYECTO_ASOGUAPO.git
cd PROYECTO_ASOGUAPO

# Cambiar a rama de desarrollo
git checkout dev

# Instalar dependencias
cd app
flutter pub get

# Ejecutar en modo debug
flutter run
```

## 📱 Pantallas

| Pantalla            | Descripción                     |
| ------------------- | ------------------------------- |
| Lista de Contadores | Listado con indicador de estado |
| Registro de Lectura | Cámara + input numérico + GPS   |
| Confirmación        | Resumen del registro guardado   |
| Historial           | Lista de lecturas + exportación |

## 📝 Flujo de Trabajo Git

```
dev → main → tag
 ↑
 trabajo diario
```

- `main` → versión estable
- `dev` → desarrollo activo
- Tags: `v0.1.0`, `v0.2.0`, etc.

## 🏷️ Convención de Commits

| Prefijo    | Uso                 |
| ---------- | ------------------- |
| `feat`     | Nueva funcionalidad |
| `fix`      | Corrección de error |
| `docs`     | Documentación       |
| `refactor` | Limpieza de código  |
| `chore`    | Configuración       |

## 📄 Licencia

Este proyecto es de uso interno para ASOGUAPO.

## 👥 Contacto

Desarrollado para la comunidad administrada por junta local de agua potable.