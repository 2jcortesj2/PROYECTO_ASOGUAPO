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

  const RegistroLecturaScreen({
    super.key,
    required this.contador,
    this.lecturaExistente,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Si hay lectura existente, pre-llenar datos
    if (widget.lecturaExistente != null) {
      _lecturaController.text = widget.lecturaExistente!.lectura
          .toStringAsFixed(0);
      if (widget.lecturaExistente!.fotoPath.isNotEmpty) {
        _fotoPath = widget.lecturaExistente!.fotoPath;
      }
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
  /// Prioriza última ubicación conocida para mejor rendimiento
  Future<void> _obtenerGps() async {
    setState(() {
      _obteniendoGps = true;
      _gpsError = null;
    });

    // Primero intentar con última ubicación conocida (más rápido)
    var result = await _gpsService.getLastKnownLocation();

    // Si no hay última ubicación, obtener actual
    if (!result.success) {
      result = await _gpsService.getCurrentLocation();
    }

    if (mounted) {
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lecturaController.dispose();
    _cameraService.dispose();
    super.dispose();
  }

  bool get _puedeGuardar {
    return _fotoPath != null &&
        _lecturaController.text.isNotEmpty &&
        !_guardando &&
        !_capturandoFoto;
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
                  // Input de lectura
                  LecturaInput(
                    controller: _lecturaController,
                    errorText: _errorLectura,
                    onChanged: (value) {
                      setState(() {
                        _errorLectura = null;
                      });
                    },
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

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📷 Foto capturada exitosamente'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
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
    if (lecturaTexto.isEmpty) {
      setState(() => _errorLectura = 'Ingresa la lectura');
      return;
    }

    final lectura = double.tryParse(lecturaTexto);
    if (lectura == null) {
      setState(() => _errorLectura = 'Lectura inválida');
      return;
    }

    if (lectura < AppConstants.lecturaMinima) {
      setState(() => _errorLectura = 'La lectura debe ser mayor a 0');
      return;
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
            builder: (context) => ConfirmacionScreen(lectura: nuevaLectura),
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
}
