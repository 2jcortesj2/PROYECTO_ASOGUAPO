import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Indicador de estado del GPS
/// Muestra visualmente si el GPS está activo y la ubicación obtenida
class GpsIndicator extends StatelessWidget {
  final bool activo;
  final bool obteniendo;
  final String? coordenadas;
  final VoidCallback? onRetry;

  const GpsIndicator({
    super.key,
    required this.activo,
    this.obteniendo = false,
    this.coordenadas,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícono GPS
          if (obteniendo)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          else
            Icon(Icons.location_on, size: 18, color: _getIconColor()),

          const SizedBox(width: 6),

          // Texto de estado
          Text(
            _getTexto(),
            style: AppTextStyles.cuerpoSecundario.copyWith(
              color: _getTextColor(),
              fontWeight: FontWeight.w500,
            ),
          ),

          // Botón reintentar si hay error
          if (!activo && !obteniendo && onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: const Icon(
                Icons.refresh,
                size: 18,
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (obteniendo) return AppColors.primary.withValues(alpha: 0.1);
    if (activo) return AppColors.success.withValues(alpha: 0.1);
    return AppColors.error.withValues(alpha: 0.1);
  }

  Color _getIconColor() {
    if (activo) return AppColors.success;
    return AppColors.error;
  }

  Color _getTextColor() {
    if (obteniendo) return AppColors.primary;
    if (activo) return AppColors.success;
    return AppColors.error;
  }

  String _getTexto() {
    if (obteniendo) return 'Obteniendo GPS...';
    if (activo) {
      if (coordenadas != null) return coordenadas!;
      return 'GPS Activo';
    }
    return 'GPS Inactivo';
  }
}

/// Indicador de fecha actual
class FechaIndicator extends StatelessWidget {
  final DateTime fecha;

  const FechaIndicator({super.key, required this.fecha});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            _formatFecha(),
            style: AppTextStyles.cuerpoSecundario.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFecha() {
    final meses = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${fecha.day} ${meses[fecha.month]} ${fecha.year}';
  }
}
