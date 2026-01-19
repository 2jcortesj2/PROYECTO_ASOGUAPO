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
import 'confirmacion_screen.dart';

/// Pantalla de registro de lectura
/// Incluye cámara real, input de lectura y GPS real
class RegistroLecturaScreen extends StatefulWidget {
  final Contador contador;

  const RegistroLecturaScreen({super.key, required this.contador});

  @override
  State<RegistroLecturaScreen> createState() => _RegistroLecturaScreenState();
}

class _RegistroLecturaScreenState extends State<RegistroLecturaScreen> {
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

  @override
  void initState() {
    super.initState();
    _obtenerGps();
  }

  /// Obtiene la ubicación GPS real
  Future<void> _obtenerGps() async {
    setState(() {
      _obteniendoGps = true;
      _gpsError = null;
    });

    final result = await _gpsService.getCurrentLocation();

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
    _lecturaController.dispose();
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
            // Vista de cámara / foto
            Expanded(flex: 5, child: _buildCameraSection()),

            // Sección inferior
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
                    texto: 'GUARDAR LECTURA',
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
          // Fondo / foto capturada
          if (_fotoPath != null)
            Image.file(
              File(_fotoPath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          else
            Container(
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _capturandoFoto
                          ? Icons.hourglass_top
                          : Icons.camera_alt_outlined,
                      size: 64,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _capturandoFoto
                          ? 'Abriendo cámara...'
                          : 'Toca el botón para tomar foto',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Marco guía
          if (_fotoPath == null && !_capturandoFoto)
            Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),

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
            child: GestureDetector(
              onTap: _capturandoFoto ? null : _tomarFoto,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _capturandoFoto ? Colors.grey : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: _capturandoFoto
                    ? const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      )
                    : Icon(
                        _fotoPath != null ? Icons.refresh : Icons.camera_alt,
                        size: 32,
                        color: AppColors.textPrimary,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Captura una foto real usando el servicio de cámara
  Future<void> _tomarFoto() async {
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

    // Crear registro de lectura
    final registro = Lectura(
      contadorId: widget.contador.id,
      nombreUsuario: widget.contador.nombre,
      sector: widget.contador.sector,
      lectura: lectura,
      fotoPath: _fotoPath!,
      latitud: _latitud,
      longitud: _longitud,
      fecha: DateTime.now(),
    );

    if (mounted) {
      // Navegar a confirmación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmacionScreen(lectura: registro),
        ),
      );
    }
  }
}
