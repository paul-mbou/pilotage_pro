import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pilotage_pro/core/theme/design_tokens.dart';
import 'package:pilotage_pro/core/theme/pilotage_theme_extension.dart';

/// Stockly-inspired [ThemeData] factories (light + dark).
abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: StocklyPalette.primary,
      brightness: Brightness.light,
    ).copyWith(
      surface: StocklyPalette.lightBackground,
      onSurface: StocklyPalette.lightTextPrimary,
      onSurfaceVariant: StocklyPalette.lightTextSecondary,
      primary: StocklyPalette.primary,
      onPrimary: StocklyPalette.onPrimary,
      primaryContainer: const Color(0xFFEFF6FF),
      onPrimaryContainer: const Color(0xFF1E3A8A),
      secondary: StocklyPalette.lightTextSecondary,
      onSecondary: StocklyPalette.lightBackground,
      error: StocklyPalette.error,
      outline: StocklyPalette.lightBorder,
      surfaceContainerHighest: StocklyPalette.lightSurfaceContainer,
    );

    final textTheme = _textTheme(colorScheme, Brightness.light);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.sourceSans3().fontFamily,
      scaffoldBackgroundColor: StocklyPalette.lightSurfaceMuted,
      textTheme: textTheme,
      extensions: const <ThemeExtension<dynamic>>[PilotageThemeTokens.light],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: StocklyPalette.lightBackground,
        foregroundColor: StocklyPalette.lightTextPrimary,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 20),
        iconTheme: const IconThemeData(color: StocklyPalette.lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: StocklyPalette.lightBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StocklyLayout.radiusLg),
          side: const BorderSide(color: Color(0x0F000000)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: StocklyPalette.lightBackground,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return textTheme.labelMedium
              ?.copyWith(color: StocklyPalette.lightTextSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return const IconThemeData(
              color: StocklyPalette.lightTextSecondary, size: 24);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Size.fromHeight → infinite width; breaks Row layout
          minimumSize: const Size(64, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
          ),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(64, 48),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StocklyLayout.radiusSm),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StocklyPalette.lightSurfaceContainer,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.55),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle:
            TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
      ),
      dividerTheme:
          DividerThemeData(color: colorScheme.outline.withValues(alpha: 0.5)),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        deleteIconColor: colorScheme.onSurfaceVariant,
        disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
        selectedColor: colorScheme.primaryContainer,
        checkmarkColor: colorScheme.onPrimaryContainer,
        labelStyle: textTheme.labelLarge
            ?.copyWith(color: colorScheme.onSurface, fontSize: 13),
        secondaryLabelStyle: textTheme.labelLarge
            ?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StocklyLayout.radiusSm),
        ),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
        ),
      ),
      dialogTheme: _dialogTheme(
        textTheme: textTheme,
        colorScheme: colorScheme,
        background: StocklyPalette.lightBackground,
        borderSide: const BorderSide(color: Color(0x0F000000)),
        barrierColor: const Color(0x99000000),
      ),
      popupMenuTheme: _popupMenuTheme(
        textTheme: textTheme,
        colorScheme: colorScheme,
        background: StocklyPalette.lightBackground,
        borderSide: const BorderSide(color: Color(0x0F000000)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: StocklyPalette.lightTextSecondary,
        textColor: StocklyPalette.lightTextPrimary,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: StocklyPalette.primary,
      brightness: Brightness.dark,
    ).copyWith(
      surface: StocklyPalette.darkBackground,
      onSurface: StocklyPalette.darkTextPrimary,
      onSurfaceVariant: StocklyPalette.darkTextSecondary,
      primary: StocklyPalette.primary,
      onPrimary: StocklyPalette.onPrimary,
      primaryContainer: const Color(0xFF1E3A8A),
      onPrimaryContainer: const Color(0xFFDBEAFE),
      secondary: StocklyPalette.darkTextSecondary,
      error: const Color(0xFFF87171),
      outline: StocklyPalette.darkBorder,
      surfaceContainerHighest: StocklyPalette.darkSurfaceElevated,
    );

    final textTheme = _textTheme(colorScheme, Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.sourceSans3().fontFamily,
      scaffoldBackgroundColor: StocklyPalette.darkBackground,
      textTheme: textTheme,
      extensions: const <ThemeExtension<dynamic>>[PilotageThemeTokens.dark],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: StocklyPalette.darkBackground,
        foregroundColor: StocklyPalette.darkTextPrimary,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 20),
        iconTheme: const IconThemeData(color: StocklyPalette.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: StocklyPalette.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StocklyLayout.radiusLg),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: StocklyPalette.darkBackground,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return textTheme.labelMedium
              ?.copyWith(color: StocklyPalette.darkTextSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return const IconThemeData(
              color: StocklyPalette.darkTextSecondary, size: 24);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(64, 48),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StocklyLayout.radiusSm),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StocklyPalette.darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
          borderSide: BorderSide(
            color: StocklyPalette.darkBorder.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle:
            TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
      ),
      dividerTheme:
          DividerThemeData(color: colorScheme.outline.withValues(alpha: 0.4)),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        deleteIconColor: colorScheme.onSurfaceVariant,
        disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
        selectedColor: colorScheme.primaryContainer,
        checkmarkColor: colorScheme.onPrimaryContainer,
        labelStyle: textTheme.labelLarge
            ?.copyWith(color: colorScheme.onSurface, fontSize: 13),
        secondaryLabelStyle: textTheme.labelLarge
            ?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StocklyLayout.radiusSm),
        ),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.45)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
        ),
      ),
      dialogTheme: _dialogTheme(
        textTheme: textTheme,
        colorScheme: colorScheme,
        background: StocklyPalette.darkSurface,
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        barrierColor: const Color(0xCC000000),
      ),
      popupMenuTheme: _popupMenuTheme(
        textTheme: textTheme,
        colorScheme: colorScheme,
        background: StocklyPalette.darkSurface,
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: StocklyPalette.darkTextSecondary,
        textColor: StocklyPalette.darkTextPrimary,
      ),
    );
  }

  static PopupMenuThemeData _popupMenuTheme({
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    required Color background,
    required BorderSide borderSide,
  }) {
    return PopupMenuThemeData(
      color: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StocklyLayout.radiusLg),
        side: borderSide,
      ),
      position: PopupMenuPosition.under,
      menuPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      textStyle: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Dialogs alignés sur [CardTheme] : surface blanche, bordure légère, M3
  /// sans [surfaceTint] agressif.
  static DialogThemeData _dialogTheme({
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    required Color background,
    required BorderSide borderSide,
    required Color barrierColor,
  }) {
    return DialogThemeData(
      constraints: const BoxConstraints(minWidth: double.infinity),
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StocklyLayout.radiusLg),
        side: borderSide,
      ),
      // Titre légèrement plus grand et plus marqué que le texte de description
      // (tous les [AlertDialog] héritent de ces styles par défaut).
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        height: 1.25,
        letterSpacing: -0.3,
      ),
      contentTextStyle: textTheme.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
      iconColor: colorScheme.onSurfaceVariant,
      actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      barrierColor: barrierColor,
      clipBehavior: Clip.antiAlias,
      // 20 px de marge de chaque côté (largeur max utile sur mobile).
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme, Brightness brightness) {
    final base = ThemeData(brightness: brightness).textTheme;
    // Source Sans 3 is the current Google Fonts family for “Source Sans”.
    return GoogleFonts.sourceSans3TextTheme(base).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
  }
}
