# Guía de Testing - GuapoLector v1.3.0

Esta guía está diseñada para que QA testers o agentes de IA configuren, ejecuten y validen la aplicación **GuapoLector**.

---

## 1. Configuración del Entorno sugerido

### Prerrequisitos
- **Flutter SDK**: ^3.10.7 o superior.
- **Android Studio / VS Code**: Con plugins de Flutter y Dart.
- **Dispositivo Físico**: Recomendado para pruebas de Cámara y GPS real.

### Preparación
1.  **Instalar dependencias**:
    ```bash
    cd app
    flutter pub get
    ```

2.  **Verificar estado**:
    ```bash
    flutter doctor
    ```

---

## 2. Pruebas Automatizadas (Regresión)

Antes de realizar cambios o pruebas manuales, asegúrate de que el núcleo del sistema es estable.

### Análisis Estático (Linter)
Ejecuta el analizador para verificar que no hay advertencias de calidad o deprecaciones.
```bash
flutter analyze
```
**Resultado Esperado:** `No issues found!`. En la v1.3.0 se han resuelto todos los warnings de `withOpacity` y llaves faltantes.

### Pruebas Unitarias y de Widget
Valida la lógica de negocio (ciclos de 15 días) y el inicio de la app.
```bash
flutter test
```
**Resultado Esperado:** `All tests passed!`.
*   `logic_test.dart`: Valida el rollover de fechas.
*   `gps_service_test.dart`: Valida el manejo de fallos de ubicación.
*   `widget_test.dart`: Valida el cargado correcto del Splash Screen con la versión v1.3.0.

---

## 3. Pruebas Manuales Críticas

### TC-01: Mapa Inteligente (Rendimiento)
*   **Acciones:** Abrir el mapa, realizar zoom rápido in/out y rotar el mapa con dos dedos.
*   **Resultado Esperado:** 
    - El movimiento debe ser fluido (60fps).
    - Los iconos (gotas) deben rotar para mantenerse siempre legibles y verticales.
    - El estado de los marcadores (Gris/Verde) debe actualizarse instantáneamente al volver de un registro.

### TC-02: Flujo de Excepción (No Lectura)
*   **Acciones:** 
    1. Abrir un medidor pendiente.
    2. Tocar "¿No se puede leer el contador?".
    3. Escribir un motivo (ej: "Perro agresivo").
    4. El campo numérico debe bloquearse.
    5. Tomar la foto (obligatoria) y Guardar.
*   **Resultado Esperado:** El registro debe guardarse con lectura `null` y el comentario visible en el historial y exportación.

### TC-03: Exportación Segmentada
*   **Acciones:** 
    1. Ir a Historial.
    2. Filtrar por una Vereda específica (ej: Pueblo Nuevo).
    3. Tocar Exportar > Solo reporte CSV.
*   **Resultado Esperado:** El archivo generado debe llamarse `LECTURAS_PUE_...csv` y contener solo los datos del filtro activo.

---

## 4. Validación de Almacenamiento

### Auto-Limpieza de Fotos
*   **Lógica:** La app elimina físicamente las fotos de más de 15 días al iniciar para no agotar la memoria del dispositivo.
*   **Prueba:** Se puede simular cambiando la fecha del sistema del teléfono a +16 días y abriendo la app. Se debe verificar que la carpeta de la app reduce su tamaño.

---

*Guía actualizada el 2026-01-31 por Antigravity.*
