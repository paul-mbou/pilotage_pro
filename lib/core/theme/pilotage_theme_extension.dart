import 'package:flutter/material.dart';

import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/core/theme/design_tokens.dart';

/// Semantic colors that are not fully covered by [ColorScheme] alone.
@immutable
class PilotageThemeTokens extends ThemeExtension<PilotageThemeTokens> {
  const PilotageThemeTokens({
    required this.stockInBackground,
    required this.stockInForeground,
    required this.stockOutBackground,
    required this.stockOutForeground,
    required this.inputFill,
    required this.heroGradientStart,
    required this.heroGradientEnd,
  });

  final Color stockInBackground;
  final Color stockInForeground;
  final Color stockOutBackground;
  final Color stockOutForeground;
  final Color inputFill;
  final Color heroGradientStart;
  final Color heroGradientEnd;

  static const PilotageThemeTokens light = PilotageThemeTokens(
    stockInBackground: StocklyPalette.stockInBackground,
    stockInForeground: StocklyPalette.stockInForeground,
    stockOutBackground: StocklyPalette.stockOutBackground,
    stockOutForeground: StocklyPalette.stockOutForeground,
    inputFill: StocklyPalette.lightSurfaceContainer,
    heroGradientStart: Color(0xFF2563EB),
    heroGradientEnd: StocklyPalette.primary,
  );

  static const PilotageThemeTokens dark = PilotageThemeTokens(
    stockInBackground: Color(0xFF172554),
    stockInForeground: Color(0xFF93C5FD),
    stockOutBackground: Color(0xFF450A0A),
    stockOutForeground: Color(0xFFFECACA),
    inputFill: StocklyPalette.darkSurface,
    heroGradientStart: Color(0xFF1E3A8A),
    heroGradientEnd: Color(0xFF3B82F6),
  );

  @override
  PilotageThemeTokens copyWith({
    Color? stockInBackground,
    Color? stockInForeground,
    Color? stockOutBackground,
    Color? stockOutForeground,
    Color? inputFill,
    Color? heroGradientStart,
    Color? heroGradientEnd,
  }) {
    return PilotageThemeTokens(
      stockInBackground: stockInBackground ?? this.stockInBackground,
      stockInForeground: stockInForeground ?? this.stockInForeground,
      stockOutBackground: stockOutBackground ?? this.stockOutBackground,
      stockOutForeground: stockOutForeground ?? this.stockOutForeground,
      inputFill: inputFill ?? this.inputFill,
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
    );
  }

  @override
  PilotageThemeTokens lerp(
      ThemeExtension<PilotageThemeTokens>? other, double t) {
    if (other is! PilotageThemeTokens) return this;
    return PilotageThemeTokens(
      stockInBackground:
          Color.lerp(stockInBackground, other.stockInBackground, t)!,
      stockInForeground:
          Color.lerp(stockInForeground, other.stockInForeground, t)!,
      stockOutBackground:
          Color.lerp(stockOutBackground, other.stockOutBackground, t)!,
      stockOutForeground:
          Color.lerp(stockOutForeground, other.stockOutForeground, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      heroGradientStart:
          Color.lerp(heroGradientStart, other.heroGradientStart, t)!,
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
    );
  }
}

extension PilotageThemeTokensX on BuildContext {
  PilotageThemeTokens get pilotageTokens =>
      theme.extension<PilotageThemeTokens>() ?? PilotageThemeTokens.light;
}
