import 'package:flutter/material.dart';

/// Paleta de colores para AguaLector
/// Optimizada para alto contraste y uso en exteriores
class AppColors {
  // Colores primarios
  static const Color primary = Color(0xFF059669); // Verde esmeralda
  static const Color primaryLight = Color(0xFF10B981); // Verde claro
  static const Color primaryDark = Color(0xFF047857); // Verde oscuro

  // Colores secundarios
  static const Color secondary = Color(0xFF0284C7); // Azul

  // Estados
  static const Color success = Color(0xFF10B981); // Verde éxito
  static const Color error = Color(0xFFDC2626); // Rojo error
  static const Color warning = Color(0xFFF59E0B); // Naranja advertencia

  // Neutrales
  static const Color background = Color(0xFFF9FAFB); // Fondo claro
  static const Color surface = Color(0xFFFFFFFF); // Superficie
  static const Color textPrimary = Color(0xFF111827); // Texto principal
  static const Color textSecondary = Color(0xFF6B7280); // Texto secundario
  static const Color border = Color(0xFFE5E7EB); // Bordes

  // Estados de contador
  static const Color pendiente = Color(0xFF6B7280); // Gris pendiente
  static const Color registrado = Color(0xFF10B981); // Verde registrado
  static const Color conError = Color(0xFFF59E0B); // Naranja error
}

/// Estilos de texto para la aplicación
class AppTextStyles {
  static const String fontFamily = 'Roboto';

  // Títulos
  static const TextStyle titulo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitulo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Cuerpo
  static const TextStyle cuerpo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle cuerpoSecundario = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Lectura grande (input numérico)
  static const TextStyle lecturaGrande = TextStyle(
    fontFamily: 'RobotoMono',
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Botones
  static const TextStyle boton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Card
  static const TextStyle cardTitulo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardSubtitulo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

/// Tema principal de la aplicación
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,

      // Colores
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
        background: AppColors.background,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.subtitulo,
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.boton,
          elevation: 0,
        ),
      ),

      // Botones outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.border, width: 2),
          textStyle: AppTextStyles.boton.copyWith(color: AppColors.textPrimary),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Cards
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}
