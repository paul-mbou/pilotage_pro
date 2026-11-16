import 'package:flutter/material.dart';

/// Shorthand for [Theme.of] on this [BuildContext].
extension BuildContextThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;
}
