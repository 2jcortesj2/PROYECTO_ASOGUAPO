import 'dart:async'; // Necesario para Timer
import 'dart:io';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/contador.dart';
import '../models/lectura.dart';
import '../services/camera_service.dart';
import '../services/gps_service.dart';
import '../widgets/boton_principal.dart';
import '../widgets/lectura_input.dart';
import '../widgets/gps_indicator.dart';
import '../widgets/camera_preview_widget.dart';
import 'confirmacion_screen.dart';
import '../services/database_service.dart';

/// Pantalla de registro de lectura
/// Incluye cámara embebida en vivo, input de lectura y GPS real
class RegistroLecturaScreen extends StatefulWidget {
  final Contador contador;
  final Lectura? lecturaExistente;
  final String? veredaOrigen;

  const RegistroLecturaScreen({
    super.key,
    required this.contador,
    this.lecturaExistente,
    this.veredaOrigen,
  });

  @override
  State<RegistroLecturaScreen> createState() => _RegistroLecturaScreenState();
}

class _RegistroLecturaScreenState extends State<RegistroLecturaScreen>
    with WidgetsBindingObserver {
  final TextEditingController _lecturaController = TextEditingController();
  final CameraService _cameraService = CameraService();
  final GpsService _gpsService = GpsService();

  String? _fotoPath;
  bool _gpsActivo = false;
  bool _obteniendoGps = true;
  double? _latitud;
  double? _longitud;
  String? _gpsError;
  bool _guardando = false;
  String? _errorLectura;
  bool _capturandoFoto = false;
  bool _cameraInitialized = false;
  String? _cameraError;
  String? _comentario;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Si hay lectura existente, pre-llenar datos
    if (widget.lecturaExistente != null) {
      _lecturaController.text =
          widget.lecturaExistente!.lectura?.toStringAsFixed(0) ?? '';
      if (widget.lecturaExistente!.fotoPath.isNotEmpty) {
        _fotoPath = widget.lecturaExistente!.fotoPath;
      }
      _comentario = widget.lecturaExistente!.comentario;
    }

    _initCamera();
    _obtenerGps();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Manejar ciclo de vida para optimizar recursos
    if (!_cameraInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  /// Inicializa la cámara embebida
  Future<void> _initCamera() async {
    final success = await _cameraService.initialize(lowResolution: true);

    if (mounted) {
      setState(() {
        _cameraInitialized = success;
        if (!success) {
          _cameraError = 'No se pudo inicializar la cámara';
        }
      });
    }
  }

  /// Obtiene la ubicación GPS real
  /// Prioriza la ubicación actual para asegurar precisión entre medidores
  Future<void> _obtenerGps() async {
    setState(() {
      _obteniendoGps = true;
      _gpsError = null;
    });

    // Iniciar temporizador de timeout (6 segundos)
    bool timeoutOcurrido = false;
    final timeoutTimer = Timer(const Duration(seconds: 6), () {
      if (_obteniendoGps && mounted) {
        timeoutOcurrido = true;
        setState(() {
          _obteniendoGps = false;
          _gpsActivo = false; // No activo, pero...
          _gpsError = 'Guardado sin GPS habilitado'; // Estado especial
        });
      }
    });

    try {
      // Intentar obtener ubicación actual
      var result = await _gpsService.getCurrentLocation();

      // Si falla, intentar con última conocida
      if (!result.success && !timeoutOcurrido) {
        final lastKnown = await _gpsService.getLastKnownLocation();
        if (lastKnown.success) {
          result = lastKnown;
        }
      }

      timeoutTimer.cancel();

      if (mounted && !timeoutOcurrido) {
        setState(() {
          _obteniendoGps = false;
          if (result.success) {
            _gpsActivo = true;
            _latitud = result.latitude;
            _longitud = result.longitude;
          } else {
            _gpsActivo = false;
            _gpsError = result.errorMessage;
          }
        });
      }
    } catch (e) {
      timeoutTimer.cancel();
      if (mounted && !timeoutOcurrido) {
        setState(() {
          _obteniendoGps = false;
          _gpsActivo = false;
          _gpsError = 'Error GPS: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lecturaController.dispose();
    _cameraService.dispose();
    super.dispose();
  }

  bool get _puedeGuardar {
    final tieneLectura = _lecturaController.text.isNotEmpty;
    final tieneComentario = _comentario != null && _comentario!.isNotEmpty;
    final tieneFoto = _fotoPath != null;

    if (_guardando || _capturandoFoto || !tieneFoto) return false;

    // Si tiene comentario (excepción), se permite guardar (con la foto obligatoria)
    // Si no tiene comentario, debe tener obligatoriamente la lectura numérica
    return tieneComentario || tieneLectura;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contador.nombre, style: AppTextStyles.subtitulo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Vista de cámara en vivo / foto capturada
            Expanded(flex: 5, child: _buildCameraSection()),

            // Sección inferior con inputs
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Input de lectura (Deshabilitado si hay comentario)
                  LecturaInput(
                    controller: _lecturaController,
                    errorText: _errorLectura,
                    enabled: _comentario == null, // Bloquear si hay motivo
                    onChanged: (value) {
                      setState(() {
                        _errorLectura = null;
                        // Si empieza a escribir, quitamos el "no se puede leer"
                        if (value.isNotEmpty) _comentario = null;
                      });
                    },
                  ),

                  // Opción discreta: No se puede leer
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _mostrarDialogoNoLectura,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: _comentario != null
                            ? Colors.orange
                            : AppColors.textSecondary,
                      ),
                      child: Text(
                        _comentario != null
                            ? 'Motivo: ${_comentario!.length > 15 ? _comentario!.substring(0, 15) + '...' : _comentario}'
                            : '¿No se puede leer el contador?',
                        style: const TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Indicadores GPS y Fecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GpsIndicator(
                        activo: _gpsActivo,
                        obteniendo: _obteniendoGps,
                        coordenadas: _gpsActivo
                            ? '${_latitud?.toStringAsFixed(4)}, ${_longitud?.toStringAsFixed(4)}'
                            : null,
                        timeoutMode: _gpsError == 'Guardado sin GPS habilitado',
                        onRetry: _gpsActivo ? null : _obtenerGps,
                      ),
                      const SizedBox(width: 16),
                      FechaIndicator(fecha: DateTime.now()),
                    ],
                  ),

                  // Mostrar error de GPS si existe
                  if (_gpsError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _gpsError!,
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Botón guardar
                  BotonPrincipal(
                    texto: widget.lecturaExistente != null
                        ? 'ACTUALIZAR LECTURA'
                        : 'GUARDAR LECTURA',
                    icono: Icons.save,
                    habilitado: _puedeGuardar,
                    cargando: _guardando,
                    onPressed: _guardarLectura,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraSection() {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Mostrar foto capturada o vista previa en vivo
          if (_fotoPath != null)
            Image.file(
              File(_fotoPath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          else if (_cameraInitialized && _cameraService.controller != null)
            CameraPreviewWidget(
              controller: _cameraService.controller!,
              overlay: const CameraGuideFrame(),
            )
          else if (_cameraError != null)
            _buildCameraError()
          else
            _buildCameraLoading(),

          // Indicador de foto tomada
          if (_fotoPath != null)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Foto capturada',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Botón de captura
          Positioned(
            bottom: 20,
            child: CaptureButton(
              isLoading: _capturandoFoto,
              hasPhoto: _fotoPath != null,
              onPressed: _tomarFoto,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraLoading() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
            SizedBox(height: 16),
            Text(
              'Iniciando cámara...',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraError() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              _cameraError ?? 'Error con la cámara',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initCamera,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Captura una foto desde la vista previa en vivo
  Future<void> _tomarFoto() async {
    // Si ya existe una foto, al tocar el botón de "refresh" volvemos a la cámara
    if (_fotoPath != null) {
      final oldPath = _fotoPath!;
      setState(() {
        _fotoPath = null;
      });
      // Eliminar el archivo anterior para ahorrar espacio
      _cameraService.deletePhoto(oldPath);

      // Refrescar GPS al intentar una nueva toma para asegurar precisión
      _obtenerGps();
      return;
    }

    if (!_cameraInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ La cámara no está lista'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _capturandoFoto = true);

    final path = await _cameraService.capturePhoto();

    if (mounted) {
      setState(() {
        _capturandoFoto = false;
        if (path != null) {
          _fotoPath = path;
        }
      });

      if (path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se pudo capturar la foto'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _guardarLectura() async {
    // Validar lectura
    final lecturaTexto = _lecturaController.text.trim();
    double? lectura;

    if (_comentario == null) {
      if (lecturaTexto.isEmpty) {
        setState(() => _errorLectura = 'Ingresa la lectura');
        return;
      }

      final l = double.tryParse(lecturaTexto);
      if (l == null) {
        setState(() => _errorLectura = 'Lectura inválida');
        return;
      }

      if (l < AppConstants.lecturaMinima) {
        setState(() => _errorLectura = 'La lectura debe ser mayor a 0');
        return;
      }
      lectura = l;
    } else {
      // Si hay comentario, la lectura es explícitamente NULL
      lectura = null;
    }

    setState(() => _guardando = true);

    // Pequeña pausa para feedback visual
    await Future.delayed(const Duration(milliseconds: 300));

    // Crear o actualizar registro de lectura
    final nuevaLectura = Lectura(
      id: widget.lecturaExistente?.id, // Mantener ID si es edición
      contadorId: widget.contador.id,
      nombreUsuario: widget.contador.nombre,
      vereda: widget.contador.vereda,
      lectura: lectura,
      fotoPath: _fotoPath ?? '',
      latitud: _latitud,
      longitud: _longitud,
      fecha: DateTime.now(),
      sincronizado: false,
      comentario: _comentario,
    );

    // Guardar en BD
    try {
      final dbService = DatabaseService();
      if (widget.lecturaExistente != null) {
        await dbService.updateLectura(nuevaLectura);
      } else {
        await dbService.insertLectura(nuevaLectura);
      }

      if (mounted) {
        // Navegar a confirmación
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmacionScreen(
              lectura: nuevaLectura,
              veredaOrigen: widget.veredaOrigen,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _guardando = false;
        _errorLectura = 'Error al guardar: $e';
      });
    }
  }

  void _mostrarDialogoNoLectura() {
    final controller = TextEditingController(text: _comentario);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Motivo de no lectura',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Describe la razón por la cual no es posible tomar la lectura numérica:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Ej: Contador roto, perro agresivo...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón limpiar/borrar motivo (si existe)
              if (_comentario != null) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _comentario = null);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('BORRAR MOTIVO'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Botón Aceptar
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() {
                      _comentario = controller.text.trim();
                      _errorLectura = null;
                      _lecturaController.clear(); // Limpiar lectura visualmente
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ACEPTAR'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
