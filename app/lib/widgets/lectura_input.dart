import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../config/constants.dart';

/// Campo de entrada para lectura de contador
/// Diseño grande y claro para uso en campo
class LecturaInput extends StatelessWidget {
  final TextEditingController controller;
  final String? unidad;
  final String? label;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String? errorText;

  const LecturaInput({
    super.key,
    required this.controller,
    this.unidad = 'm³',
    this.label = 'Lectura actual',
    this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: AppTextStyles.cuerpo.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.border,
              width: errorText != null ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Campo de texto
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.lecturaGrande,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.border,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: onChanged,
                ),
              ),

              // Unidad
              if (unidad != null)
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    unidad!,
                    style: AppTextStyles.subtitulo.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Mensaje de error
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              style: AppTextStyles.cuerpoSecundario.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}
