# Plan de Implementación - Guía de Testing para AguaLector

## Objetivo
Crear un documento estandarizado (`docs/TESTING.md`) que permita a cualquier agente (humano o IA) configurar el entorno, ejecutar el proyecto y validar funcionalmente el prototipo v0.1.0 de la aplicación AguaLector.

## Archivos Afectados
- `docs/TESTING.md` (Nuevo)

## Estructura de la Guía de Testing

### 1. Configuración del Entorno de Prueba
- Instrucciones para clonar el repo.
- Requisitos previos (Flutter SDK, Android Emulator).
- Comandos para limpiar y construir el proyecto.

### 2. Verificación de Calidad de Código (Static Analysis)
- Ejecución de `flutter analyze` para detectar warnings/errors.
- Ejecución de `flutter test` (aunque no haya tests unitarios aún, para verificar setup).

### 3. Suite de Pruebas Manuales (Prototipo v0.1.0)
Definición de casos de prueba paso a paso:

| ID        | Nombre del Caso           | Precondición | Pasos Principales                                | Resultado Esperado                                |
| --------- | ------------------------- | ------------ | ------------------------------------------------ | ------------------------------------------------- |
| **TC-01** | Visualización de Lista    | App abierta  | Scroll en lista                                  | Ver 6 contadores de prueba con diferentes estados |
| **TC-02** | Búsqueda de Contador      | En Lista     | Escribir "Rosario"                               | Filtrar lista solo mostrando coincidencias        |
| **TC-03** | Flujo de Registro Exitoso | En Lista     | Seleccionar contador -> Foto -> Valor -> Guardar | Ver pantalla éxito y volver a lista               |
| **TC-04** | Validación de Entradas    | En Registro  | Intentar guardar vacío o valor 0                 | Mostrar mensaje de error en rojo                  |
| **TC-05** | Navegación Historial      | En Lista     | Ir a Historial -> Filtros                        | Ver chips de filtros y botón exportar funcional   |

### 4. Reporte de Bugs
- Formato sugerido para reportar incidencias encontradas durante el testing.

## Verificación
- El archivo markdown debe ser renderizable correctamente en GitHub.
- Los comandos deben ser ejecutables en terminal Windows/Powershell.
