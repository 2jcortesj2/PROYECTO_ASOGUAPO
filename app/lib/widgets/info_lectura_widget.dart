import 'dart:io';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/lectura.dart';

/// Widget reutilizable para mostrar los detalles de una lectura
/// con el mismo estilo en toda la aplicación.
class InfoLecturaWidget extends StatelessWidget {
  final Lectura lectura;
  final bool mostrarFoto;

  const InfoLecturaWidget({
    super.key,
    required this.lectura,
    this.mostrarFoto = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mostrarFoto) ...[
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildFotoPreview(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Caja de detalles
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildDetalleRow(
                Icons.speed,
                'Valor Marcado',
                lectura.lecturaFormateada,
              ),
              const Divider(height: 24, thickness: 1),
              _buildDetalleRow(
                Icons.calendar_today,
                'Fecha Registro',
                lectura.diaMesAno,
              ),
              const SizedBox(height: 12),
              _buildDetalleRow(
                Icons.access_time,
                'Hora exacta',
                lectura.horaMinuto,
              ),
              const SizedBox(height: 12),
              _buildDetalleRow(
                Icons.location_on,
                'Ubicación GPS',
                lectura.ubicacionFormateada,
              ),
              if (lectura.comentario != null &&
                  lectura.comentario!.isNotEmpty) ...[
                const Divider(height: 24, thickness: 1),
                _buildDetalleRow(
                  Icons.comment,
                  'Observación',
                  lectura.comentario!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFotoPreview() {
    if (lectura.fotoPath.isNotEmpty) {
      final file = File(lectura.fotoPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[400],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 40, color: Colors.white),
            SizedBox(height: 4),
            Text(
              'Sin Foto',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleRow(IconData icono, String label, String valor) {
    return Row(
      children: [
        Icon(icono, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: AppTextStyles.cuerpo.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            valor,
            style: AppTextStyles.cuerpo.copyWith(fontSize: 13),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
