import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar la vista previa de la cámara
/// Optimizado para rendimiento con RepaintBoundary
class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final Widget? overlay;
  final VoidCallback? onTapCapture;

  const CameraPreviewWidget({
    super.key,
    required this.controller,
    this.overlay,
    this.onTapCapture,
  });

  @override
  Widget build(BuildContext context) {
    // Si la cámara no está inicializada, mostrar loading
    if (!controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              SizedBox(height: 16),
              Text(
                'Iniciando cámara...',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Usar RepaintBoundary para evitar rebuilds innecesarios
    return RepaintBoundary(
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Vista previa de la cámara
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            ),

            // Overlay personalizado (marco guía, botones, etc.)
            if (overlay != null) overlay!,
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar el marco guía de enfoque
class CameraGuideFrame extends StatelessWidget {
  final double width;
  final double height;

  const CameraGuideFrame({super.key, this.width = 200, this.height = 150});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.7),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Widget para el botón de captura de foto
class CaptureButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool hasPhoto;

  const CaptureButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.hasPhoto = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey : Colors.white,
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
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              )
            : Icon(
                hasPhoto ? Icons.refresh : Icons.camera_alt,
                size: 32,
                color: Colors.black87,
              ),
      ),
    );
  }
}
