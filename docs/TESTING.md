# Guía de Testing - GuapoLector v1.0.1

Esta guía está diseñada para que QA testers o agentes de IA configuren, ejecuten y validen el prototipo funcional de la aplicación **GuapoLector**.

---

## 1. Configuración del Entorno

### Prerrequisitos
- **Flutter SDK**: 3.x o superior instalado y en el PATH.
- **Android Studio** con emulador configurado o dispositivo físico conectado.
- **Git** instalado.

### Pasos de Instalación
1.  **Clonar el repositorio** (si aún no lo tienes):
    ```bash
    git clone https://github.com/2jcortesj2/PROYECTO_ASOGUAPO.git
    cd PROYECTO_ASOGUAPO
    ```

2.  **Cambiar a la rama de desarrollo** (donde están los últimos cambios):
    ```bash
    git checkout dev
    ```

3.  **Instalar dependencias**:
    ```bash
    cd app
    flutter pub get
    ```

4.  **Verificar instalación**:
    ```bash
    flutter doctor
    ```
    *Asegúrate de tener todos los checks en verde, especialmente Flutter y Android toolchain.*

### Ejecución de la App
Para correr la aplicación en el emulador o dispositivo conectado:
```bash
flutter run
```

---

## 2. Análisis Estático de Código

Antes de realizar pruebas manuales, verifica la salud del código.

### Linter (Code Analysis)
Ejecuta el analizador oficial de Flutter para detectar errores de sintaxis, tipos o malas prácticas.
```bash
flutter analyze
```
**Resultado Esperado:** 
- `No issues found!` o, en el peor de los casos, solo warnings de deprecación (como `withOpacity` en Flutter 3.27+). No debe haber errores (`errors`) que impidan la compilación.

---

## 3. Suite de Pruebas Manuales (Prototipo UI)

Ejecuta estos casos de prueba en orden para validar el flujo crítico de la aplicación.

### TC-01: Visualización de Lista de Contadores
*   **Objetivo:** Verificar que la pantalla principal carga datos y muestra estados.
*   **Acciones:**
    1.  Abrir la aplicación.
    2.  Observar la lista de contadores.
*   **Resultado Esperado:**
    - [ ] Se muestra título "Lecturas del Día" con fecha actual.
    - [ ] Se listan al menos 5 contadores de prueba.
    - [ ] Hay contadores con estados visuales distintos: icono verde (registrado), gris (pendiente), naranja (error).

### TC-02: Búsqueda y Filtrado
*   **Objetivo:** Validar la funcionalidad de búsqueda local.
*   **Acciones:**
    1.  En la pantalla principal, tocar la barra de búsqueda.
    2.  Escribir "Rosario".
*   **Resultado Esperado:**
    - [ ] La lista se filtra dinámicamente.
    - [ ] Solo aparecen contadores que contienen "Rosario" en su nombre o sector.
    - [ ] El contador de resultados ("X contadores") se actualiza.

### TC-03: Flujo de Registro de Lectura (Happy Path)
*   **Objetivo:** Completar el registro de un medidor pendiente.
*   **Acciones:**
    1.  Tocar un contador con estado "Pendiente" (gris).
    2.  Verificar que se abre la pantalla de "Registro".
    3.  Esperar 2 segundos a que el GPS simulado se active (pin verde).
    4.  Tocar el botón de cámara (círculo) para simular captura.
    5.  Ingresar "1500" en el campo de lectura.
    6.  Tocar "GUARDAR LECTURA".
*   **Resultado Esperado:**
    - [ ] Aparece snackbar "Foto capturada".
    - [ ] GPS cambia a "Activo" con coordenadas simuladas.
    - [ ] Transición a pantalla de Confirmación (Check verde animado).
    - [ ] Se muestran los datos ingresados (1500 m³, fecha, ubicación).

### TC-04: Validación de Entradas
*   **Objetivo:** Verificar que no se guarden datos inválidos.
*   **Acciones:**
    1.  Abrir un registro nuevo.
    2.  No tomar foto.
    3.  Dejar campo de lectura vacío o escribir texto no numérico (si el teclado lo permitiera).
    4.  Tocar "GUARDAR LECTURA".
*   **Resultado Esperado:**
    - [ ] El botón guardar permanece deshabilitado o muestra error al presionar.
    - [ ] Mensaje "Ingresa la lectura" o similar si se intenta forzar.

### TC-05: Historial y Exportación
*   **Objetivo:** Verificar acceso a historial y menús de exportación.
*   **Acciones:**
    1.  Volver a la pantalla principal.
    2.  Tocar el botón flotante (FAB) de Historial.
    3.  Probar los chips de filtro "Hoy", "Semana", "Mes".
    4.  Tocar botón "EXPORTAR DATOS" al final.
*   **Resultado Esperado:**
    - [ ] Se muestran tarjetas de lecturas pasadas.
    - [ ] Se abre un modal inferior (BottomSheet) con opciones "Exportar CSV" y "Compartir".
    - [ ] Al seleccionar una opción, aparece un mensaje de confirmación "Exportando...".

---

## 4. Reporte de Incidencias

Si encuentras un error, por favor repórtalo con el siguiente formato:

```markdown
### [BUG] Título descriptivo
- **Pantalla:** (Main / Registro / Historial)
- **Pasos para reproducir:**
  1. ...
  2. ...
- **Comportamiento esperado:** ...
- **Comportamiento actual:** ...
- **Screenshot/Log:** (Opcional)
```
