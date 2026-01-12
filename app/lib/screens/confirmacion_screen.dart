import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/lectura.dart';
import '../widgets/boton_principal.dart';
import 'lista_contadores_screen.dart';

/// Pantalla de confirmación de lectura guardada
class ConfirmacionScreen extends StatefulWidget {
  final Lectura lectura;

  const ConfirmacionScreen({super.key, required this.lectura});

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
                    color: AppColors.success.withOpacity(0.1),
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

              // Miniatura de la foto
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildFotoPreview(),
                ),
              ),

              const SizedBox(height: 32),

              // Detalles de la lectura
              _buildDetalleRow(
                icono: Icons.speed,
                label: 'Lectura',
                valor: widget.lectura.lecturaFormateada,
              ),
              const SizedBox(height: 12),
              _buildDetalleRow(
                icono: Icons.calendar_today,
                label: 'Fecha',
                valor: widget.lectura.fechaFormateada,
              ),
              const SizedBox(height: 12),
              _buildDetalleRow(
                icono: Icons.location_on,
                label: 'Ubicación',
                valor: widget.lectura.ubicacionFormateada,
              ),

              const Spacer(),

              // Botones de acción
              BotonPrincipal(
                texto: 'SIGUIENTE CONTADOR',
                icono: Icons.arrow_forward,
                onPressed: _siguienteContador,
              ),
              const SizedBox(height: 12),
              BotonPrincipal(
                texto: 'VOLVER A LA LISTA',
                esSecundario: true,
                onPressed: _volverALista,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFotoPreview() {
    // En el prototipo mostramos un placeholder
    // En producción usaríamos Image.file(File(widget.lectura.fotoPath))
    return Container(
      color: Colors.grey[400],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'Foto del\ncontador',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleRow({
    required IconData icono,
    required String label,
    required String valor,
  }) {
    return Row(
      children: [
        Icon(icono, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: AppTextStyles.cuerpo.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            valor,
            style: AppTextStyles.cuerpo,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _siguienteContador() {
    // En producción, iría al siguiente contador pendiente
    // Por ahora volvemos a la lista
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ListaContadoresScreen()),
      (route) => false,
    );
  }

  void _volverALista() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ListaContadoresScreen()),
      (route) => false,
    );
  }
}
