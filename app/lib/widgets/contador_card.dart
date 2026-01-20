import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/contador.dart';

/// Card para mostrar un contador en la lista principal
class ContadorCard extends StatelessWidget {
  final Contador contador;
  final VoidCallback? onTap;

  const ContadorCard({super.key, required this.contador, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              // Indicador de estado
              _buildEstadoIndicador(),
              const SizedBox(width: 16),

              // Información del contador
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contador.nombre,
                      style: AppTextStyles.cardTitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sector: ${contador.ubicacionCompleta}',
                      style: AppTextStyles.cardSubtitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Anterior: ${contador.ultimaLecturaFormateada} (Mes Pasado)',
                      style: AppTextStyles.cardSubtitulo.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Flecha de navegación
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoIndicador() {
    IconData icono;
    Color color;

    switch (contador.estado) {
      case EstadoContador.pendiente:
        icono = Icons.radio_button_unchecked;
        color = AppColors.pendiente;
        break;
      case EstadoContador.registrado:
        icono = Icons.check_circle;
        color = AppColors.registrado;
        break;
      case EstadoContador.conError:
        icono = Icons.warning_rounded;
        color = AppColors.conError;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      child: Icon(icono, color: color, size: 32),
    );
  }
}
