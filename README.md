# AguaLector 💧 v0.3.0

Aplicación móvil Android para registro de lecturas de contadores de agua potable en comunidades rurales.

## 🎯 Estado Actual: Fase 3 - Cámara Embebida y Gestión de Permisos

Permitir a lectores comunitarios registrar lecturas de contadores de agua de forma simple, rápida y sin conexión a internet. La versión actual incluye captura de cámara en vivo integrada directamente en la interfaz.

## ✨ Características Principales

- 📋 Lista de contadores por vereda
- 📷 Captura de foto con cámara en vivo (embebida)
- 🔢 Registro manual de lectura
- 📍 Geolocalización automática (GPS)
- 📅 Marca de tiempo automática
- 💾 Almacenamiento local (offline)
- 📤 Exportación a CSV/Excel

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