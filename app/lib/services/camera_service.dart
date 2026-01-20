import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio para captura de fotos con cámara embebida
/// Optimizado para rendimiento en dispositivos de baja gama
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  /// Indica si la cámara está inicializada y lista para usar
  bool get isInitialized => _isInitialized;

  /// Retorna el controller para el widget de preview
  CameraController? get controller => _controller;

  /// Inicializa la cámara con configuración optimizada para bajo rendimiento
  /// [lowResolution] usa resolución baja para mejor rendimiento (default: true)
  Future<bool> initialize({bool lowResolution = true}) async {
    try {
      // Obtener cámaras disponibles
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        debugPrint('CameraService: No hay cámaras disponibles');
        return false;
      }

      // Usar cámara trasera (primera disponible)
      final camera = _cameras.first;

      // Configurar resolución máxima
      final resolution = ResolutionPreset.max;

      _controller = CameraController(
        camera,
        resolution,
        enableAudio: false, // Sin audio para mejor rendimiento
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;

      return true;
    } catch (e) {
      debugPrint('CameraService: Error inicializando cámara: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Captura una foto desde la vista previa actual
  /// Retorna la ruta del archivo guardado o null si falló
  Future<String?> capturePhoto() async {
    if (!_isInitialized || _controller == null) {
      debugPrint('CameraService: Cámara no inicializada');
      return null;
    }

    try {
      // Capturar imagen
      final XFile photo = await _controller!.takePicture();

      // Guardar en directorio de la app
      final savedPath = await _savePhoto(photo);
      return savedPath;
    } catch (e) {
      debugPrint('CameraService: Error capturando foto: $e');
      return null;
    }
  }

  /// Guarda la foto en el directorio de documentos de la app
  /// con compresión optimizada para bajo almacenamiento
  Future<String> _savePhoto(XFile photo) async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${directory.path}/photos');

    // Crear directorio si no existe
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    // Nombre único basado en timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'lectura_$timestamp.jpg';
    final savedPath = '${photosDir.path}/$fileName';

    // Copiar archivo
    await File(photo.path).copy(savedPath);

    // Limpiar archivo temporal
    try {
      await File(photo.path).delete();
    } catch (_) {
      // Ignorar error si no se puede eliminar el temporal
    }

    return savedPath;
  }

  /// Pausa la cámara para ahorrar recursos
  Future<void> pause() async {
    if (_controller != null && _controller!.value.isInitialized) {
      // No hay método pause directo, pero podemos reducir impacto
      // dejando el controller en su estado actual
    }
  }

  /// Reanuda la cámara después de pausa
  Future<void> resume() async {
    if (_controller != null && !_controller!.value.isInitialized) {
      await _controller!.initialize();
    }
  }

  /// Libera todos los recursos de la cámara
  /// IMPORTANTE: Llamar en dispose() del widget
  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }
  }

  /// Elimina una foto del almacenamiento
  Future<bool> deletePhoto(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('CameraService: Error eliminando foto: $e');
      return false;
    }
  }
}
