# Lógica de Negocio - AguaLector 💧

En este documento se detallan las reglas y procesos automáticos que rigen el funcionamiento de la aplicación.

---

## 1. Ciclo de Vida de una Lectura (Regla de los 15 Días)

Para equilibrar la flexibilidad del usuario y el rendimiento del dispositivo, se ha implementado un sistema de "Periodo Activo".

- **Ventana de Edición:** Una lectura registrada se considera "Activa" durante **15 días calendarios** a partir de la fecha de captura. Durante este tiempo, el usuario puede:
  - Ver el detalle de la lectura.
  - Corregir el valor numérico.
  - Eliminar el registro completo (incluyendo la foto).
- **Cierre Automático:** Pasados los 15 días, la lectura se marca internamente como "Cerrada". Ya no aparecerá en la lista de contadores como un registro editable.

## 2. Mantenimiento Automático (Clean-up)

Cada vez que el usuario ingresa a la **Lista de Contadores**, el sistema ejecuta un proceso de mantenimiento transparente:

1. **Liberación de Almacenamiento:** Todas las fotos asociadas a lecturas con más de 15 días de antigüedad son eliminadas físicamente del teléfono.
2. **Depuración de Base de Datos:** Los registros de lectura antiguos conservan sus datos numéricos y coordenadas, pero pierden el enlace al archivo de imagen para evitar errores de "archivo no encontrado".

## 3. Rollover de Ciclo Mensual

El sistema prepara automáticamente el siguiente mes de trabajo sin necesidad de "Reiniciar" la aplicación:

- **Cambio de Estado:** Cuando una lectura supera los 15 días, el contador asociado vuelve automáticamente al estado **Pendiente** (Blanco/Gris).
- **Actualización de Baseline:** El valor de la última lectura registrada se convierte automáticamente en la nueva **Lectura Anterior**.
- **Resultado:** El lector ve el medidor disponible para una nueva toma, con el histórico actualizado, garantizando la continuidad del cálculo del consumo (Lectura Actual - Lectura Anterior).

## 4. Estrategia de Exportación (Resiliencia)

Para garantizar que los datos lleguen completos a la junta administradora, la exportación sigue reglas estrictas:

- **ZIP Maestro:** Todas las exportaciones se empaquetan en un único archivo comprimido. Esto soluciona problemas de compatibilidad con WhatsApp, donde a veces solo se enviaba un archivo cuando se seleccionaban varios.
- **Estructura Interna:** El reporte CSV se ubica en la raíz del ZIP, y las evidencias fotográficas en una carpeta interna `/fotos/`.
- **Procesamiento Asíncrono (Isolates):** La compresión de archivos se realiza en un hilo de ejecución separado del sistema operativo. Esto evita que la interfaz de la aplicación se congele o bloquee durante el empaquetado de grandes volúmenes de datos.

## 5. Persistencia de Filtros

La aplicación prioriza la comodidad del usuario mediante la memoria de estado:
- **Sincronización:** Si seleccionas una vereda específica en el Historial, al volver a la Lista principal, la aplicación mantendrá ese mismo filtro aplicado.
- **Filtro por Defecto:** Al iniciar, la aplicación precarga la vereda de la última lectura capturada, asumiendo que el usuario continúa trabajando en la misma zona geográfica.
