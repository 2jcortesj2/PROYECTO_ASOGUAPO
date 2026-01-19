import 'dart:io';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/contador.dart';
import '../models/lectura.dart';
import '../widgets/boton_principal.dart';
import '../widgets/lectura_input.dart';
import '../widgets/gps_indicator.dart';
import 'confirmacion_screen.dart';

/// Pantalla de registro de lectura
/// Incluye cámara, input de lectura y GPS
class RegistroLecturaScreen extends StatefulWidget {
  final Contador contador;

  const RegistroLecturaScreen({super.key, required this.contador});

  @override
  State<RegistroLecturaScreen> createState() => _RegistroLecturaScreenState();
}

class _RegistroLecturaScreenState extends State<RegistroLecturaScreen> {
  final TextEditingController _lecturaController = TextEditingController();

  String? _fotoPath;
  bool _gpsActivo = false;
  bool _obteniendoGps = true;
  double? _latitud;
  double? _longitud;
  bool _guardando = false;
  String? _errorLectura;

  @override
  void initState() {
    super.initState();
    _simularGps();
  }

  // Simula la obtención de GPS para el prototipo
  Future<void> _simularGps() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _gpsActivo = true;
        _obteniendoGps = false;
        _latitud = 4.5923;
        _longitud = -74.0836;
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
        !_guardando;
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
                        coordenadas: _gpsActivo ? 'GPS Activo' : null,
                        onRetry: _gpsActivo ? null : _simularGps,
                      ),
                      const SizedBox(width: 16),
                      FechaIndicator(fecha: DateTime.now()),
                    ],
                  ),

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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 64,
                      color: Colors.white54,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Vista de cámara',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Marco guía
          if (_fotoPath == null)
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
              onTap: _tomarFoto,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
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
                child: Icon(
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

  void _tomarFoto() {
    // Simulación para prototipo - en producción usar image_picker
    setState(() {
      // Simula que se tomó una foto
      _fotoPath = '/path/to/simulated/photo.jpg';
    });

    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📷 Foto capturada'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

    // Simular guardado
    await Future.delayed(const Duration(milliseconds: 800));

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
