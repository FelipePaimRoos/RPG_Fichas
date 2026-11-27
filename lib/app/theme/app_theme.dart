import 'package:app_flutter/app/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Tema do app. O web é sempre escuro; a réplica Flutter segue o mesmo
/// visual, montado a partir dos tokens em `tokens.dart`.
abstract final class AppTheme {
  /// Tema escuro idêntico ao visual do app web.
  static ThemeData get dark => _build();

  static ThemeData _build() {
    const scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accentCyan,
      surface: AppColors.card,
      onSurface: AppColors.text,
      error: AppColors.error,
      onError: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: AppTypography.fontFamily,
      visualDensity: VisualDensity.standard,
    );

    final textTheme = base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        color: AppColors.text,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(color: AppColors.text),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(color: AppColors.text),
      bodySmall: base.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.bg,
      // Botões do web: fundo primary, texto branco, bold, raio 4, padding 8x14.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: AppTypography.fontFamily,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: AppTypography.fontFamily,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
        ),
      ),
      // Inputs do web: fundo #16161a, borda #3f3f52, raio 4, foco primary.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBg,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: _border(AppColors.inputBorder),
        enabledBorder: _border(AppColors.inputBorder),
        focusedBorder: _border(AppColors.primary),
        labelStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 13.6,
          fontFamily: AppTypography.fontFamily,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 13.6,
          fontFamily: AppTypography.fontFamily,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x557289DA),
        selectionHandleColor: AppColors.primary,
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(color: Colors.white, fontSize: 15.2),
      ),
      // Modais do web: fundo card, borda, raio 8.
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: AppColors.inputBorder),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.inputBg,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.inputBorder),
        trackColor: WidgetStateProperty.all(AppColors.bg),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(8),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.cardBorder),
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: BorderSide(color: color),
      );
}
