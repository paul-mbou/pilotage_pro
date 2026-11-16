import 'package:flutter/material.dart';

/// Stockly-style inventory UI kit — raw design tokens (light + dark references).
/// See: https://tailwindcss.com/docs/customizing-colors for scale alignment.
abstract final class StocklyPalette {
  /// Primary blue — buttons, FAB, active nav, hero cards, quantity badges.
  static const Color primary = Color(0xFF3B82F6);

  /// Alternate primary from kit screens (#3B71E8); use for subtle variety.
  static const Color primaryAlt = Color(0xFF3B71E8);

  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Light — scaffold & cards
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF9FAFB);
  static const Color lightSurfaceContainer = Color(0xFFF1F4F9);
  static const Color lightBorder = Color(0xFFE1E2E9);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  /// Stock In — soft blue tint + primary accent
  static const Color stockInBackground = Color(0xFFF0F7FF);
  static const Color stockInForeground = primary;

  /// Stock Out — soft red tint
  static const Color stockOutBackground = Color(0xFFFFF0F0);
  static const Color stockOutForeground = Color(0xFFFF5C5C);

  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  /// Dark — scaffold & surfaces (Stockly dark kit)
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceElevated = Color(0xFF242424);
  static const Color darkBorder = Color(0xFF2D2D2D);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
}

/// Layout tokens — spacing & corner radii used across the kit.
abstract final class StocklyLayout {
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusSheet = 20;

  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 20;
  static const double spaceXl = 24;

  static BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
}
