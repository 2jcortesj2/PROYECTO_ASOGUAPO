import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/lectura.dart';
import '../widgets/boton_principal.dart';
import '../widgets/info_lectura_widget.dart';
import 'lista_contadores_screen.dart';

/// Pantalla de confirmación de lectura guardada
class ConfirmacionScreen extends StatefulWidget {
  final Lectura lectura;
  final String? veredaOrigen;

  const ConfirmacionScreen({
    super.key,
    required this.lectura,
    this.veredaOrigen,
  });

  @override
  State<ConfirmacionScreen> createState() => _ConfirmacionScreenState();
}

class _ConfirmacionScreenState extends State<ConfirmacionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            children: [
              const Spacer(),

              // Ícono de éxito animado
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppColors.success,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Texto de confirmación
              Text(
                'GUARDADO',
                style: AppTextStyles.titulo.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // Detalles de la lectura (Widget unificado)
              InfoLecturaWidget(lectura: widget.lectura),

              const Spacer(),

              // Botón de acción
              BotonPrincipal(
                texto: 'VOLVER A LA LISTA',
                icono: Icons.arrow_forward,
                onPressed: _volverALista,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _volverALista() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListaContadoresScreen(veredaInicial: widget.veredaOrigen),
      ),
      (route) => false,
    );
  }
}
