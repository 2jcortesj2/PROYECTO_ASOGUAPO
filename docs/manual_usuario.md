# Manual de Usuario - AguaLector 💧

## Introducción

AguaLector es una aplicación móvil diseñada para facilitar el registro de lecturas de contadores de agua potable en comunidades rurales.

---

## Requisitos

- Teléfono Android (versión 5.0 o superior)
- Permisos de Cámara y Ubicación concedidos (se solicitan al inicio)
- GPS activado
- No requiere internet

### Inicio de la Aplicación
Al abrir AguaLector, verás una **Pantalla de Inicio (Splash Screen)** durante unos segundos con el logo de Asoguapo mientras la aplicación prepara todos los datos. Es normal que esto tome entre 2 y 3 segundos.

---

## Pantallas de la Aplicación

### 1. Lista de Contadores

Al abrir la app verás la lista de todos los contadores de tu zona.

**Indicadores de estado:**
- ⚪ Gris = Pendiente de lectura (Lectura mes anterior visible)
- ✅ Verde = Lectura completada
- 🟠 Naranja = Error en el contador / lectura previa irregular

**Opciones de visualización:**
- **Filtro por Vereda:** Selecciona "El Recreo", "Pueblo Nuevo" o "El Tendido". La app recordará tu selección.
- **Ocultar completados:** Activa el interruptor para ver solo los medidores que faltan por leer hoy.

**Para buscar:** Usa la barra de búsqueda para encontrar a un usuario por nombre.

**Para registrar:** Toca la tarjeta del usuario para iniciar el registro. 

Si el usuario ya tiene una lectura en el **periodo activo (últimos 15 días)**, se abrirá un resumen donde podrás:
- **Corregir / Editar**: Si te equivocaste en el número.
- **Eliminar Registro**: Si deseas borrar la lectura por completo.

> 💡 **Nota sobre almacenamiento:** Para que tu teléfono no se llene de fotos, la aplicación borrará automáticamente las imágenes de las lecturas que tengan más de 15 días. Los datos numéricos se guardarán siempre en el historial, pero la foto se elimina para liberar espacio.

---

### 2. Registro de Lectura

**Pasos:**

1. **Ver cámara en vivo**: La cámara se activa automáticamente al entrar a la pantalla.
2. **Apunta al contador**: Mantén el teléfono firme frente al contador de agua.
3. **Presiona el botón blanco**: Toca el círculo blanco grande para capturar la foto.
4. **Ingresa la lectura**: Escribe el número actual en el campo blanco grande.
5. **Verifica el GPS**: Asegúrate de ver las coordenadas en verde bajo la lectura.
6. **Toca "GUARDAR LECTURA"**: Guarda el registro completo.

> ⚠️ **Importante:** 
> - Si el GPS muestra error, toca el ícono de reintentar
> - La foto se guarda automáticamente en tu dispositivo
> - Puedes volver a tomar la foto tocando el botón de refresh

**Sobre el GPS:**
La aplicación intentará obtener tu ubicación exacta durante 6 segundos.
- Si tarda más de ese tiempo (ej: si estás en una zona muy rural o techada), el indicador se pondrá **amarillo**.
- Esto significa que **PUEDES GUARDAR** la lectura aunque no tengas GPS activo. La prioridad es guardar el dato y la foto.

**¿No puedes leer el contador?**
Si el contador está rayado, tapado, es ilegible o no puedes acceder a él:
1. Toca la opción discreta que dice **"¿No se puede leer el contador?"** bajo el campo de lectura.
2. Explica el motivo en la ventana que aparece y pulsa **ACEPTAR**.
3. Verás que el campo de lectura se pone en **gris** (bloqueado) para indicar que no se guardará número.
4. **Toma la foto**: Es **OBLIGATORIO** tomar una foto para dejar constancia.
5. Toca **"GUARDAR LECTURA"**.

---

### 3. Confirmación

Después de guardar verás:
- ✅ Mensaje de éxito
- Miniatura de la foto
- Lectura guardada
- Fecha y Hora (separadas para mayor claridad)
- Ubicación GPS

**Opciones:**
- "Volver a la Lista" → Regresa a la lista principal manteniendo la vereda seleccionada.

---

### 4. Historial

Accede desde el botón flotante (ícono de descarga) en la lista principal.

**Funciones:**
- Ver todas las lecturas con su **foto real**.
- **Filtros por Vereda:** Filtra rápidamente para ver solo "Pueblo Nuevo", "El Recreo" o "El Tendido".
- **Exportación Inteligente:** Genera archivos CSV con el código de la vereda en el nombre (ej: LECTURAS_PUE_...csv).

**Para exportar:**
1. Selecciona la vereda específica que deseas exportar (ej: El Recreo).
2. Toca "EXPORTAR DATOS" y elige una de las 3 opciones:
    - **Solo reporte CSV**: Descarga solo la tabla de datos.
    - **Solo fotos (ZIP)**: Descarga solo las imágenes capturadas.
    - **Exportar TODO**: Descarga ambos archivos para un reporte completo.
3. Comparte los archivos por WhatsApp u otro medio.

---

## Solución de Problemas

| App no abre          | Verifica los permisos de Cámara y GPS al inicio |
| GPS no funciona      | Activa ubicación en ajustes del teléfono        |
| Foto borrosa         | Limpia la cámara y mantén el teléfono firme     |
| No guarda            | Verifica que el campo de lectura no esté vacío  |
| App lenta (Gama baja) | Cierra otras aplicaciones                       |

---

## Consejos

- ☀️ En días soleados, aumenta el brillo de la pantalla
- 📷 Toma la foto de frente al contador
- 🔢 Verifica dos veces el número antes de guardar
- 💾 Exporta los datos al final del día

---

## Contacto

Para soporte técnico, contacta a tu administrador de junta local.
