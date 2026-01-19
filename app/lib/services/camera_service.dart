import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Servicio para captura de fotos
class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Verifica y solicita permiso de cámara
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Captura una foto y la guarda en almacenamiento local
  /// Retorna la ruta del archivo guardado o null si falló
  Future<String?> capturePhoto() async {
    try {
      // Verificar permiso
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        return null;
      }

      // Capturar foto
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 960,
        imageQuality: 80,
      );

      if (photo == null) {
        return null;
      }

      // Guardar en directorio de la app
      final savedPath = await _savePhoto(photo);
      return savedPath;
    } catch (e) {
      print('Error capturando foto: $e');
      return null;
    }
  }

  /// Guarda la foto en el directorio de documentos de la app
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

    return savedPath;
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
      print('Error eliminando foto: $e');
      return false;
    }
  }
}
