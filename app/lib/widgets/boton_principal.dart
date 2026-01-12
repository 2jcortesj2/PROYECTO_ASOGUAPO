import 'package:flutter/material.dart';

/// Botón principal de la aplicación
/// Diseñado con tamaño grande para uso en campo
class BotonPrincipal extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final VoidCallback? onPressed;
  final bool habilitado;
  final bool cargando;
  final bool esSecundario;

  const BotonPrincipal({
    super.key,
    required this.texto,
    this.icono,
    this.onPressed,
    this.habilitado = true,
    this.cargando = false,
    this.esSecundario = false,
  });

  @override
  Widget build(BuildContext context) {
    if (esSecundario) {
      return OutlinedButton(
        onPressed: habilitado && !cargando ? onPressed : null,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
        child: _buildContent(),
      );
    }

    return ElevatedButton(
      onPressed: habilitado && !cargando ? onPressed : null,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (cargando) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icono != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 24),
          const SizedBox(width: 12),
          Text(texto),
        ],
      );
    }

    return Text(texto);
  }
}
