import 'package:intl/intl.dart';

/// Devise (Franc CFA) : formatage localisé des nombres, sans libellé.
abstract final class AppCurrency {
  AppCurrency._();

  static const String code = 'XAF';

  static final NumberFormat _intFr = NumberFormat('#,##0', 'fr_FR');

  static String formatNumber(num value) {
    if (value.isNaN) return '0';
    if (value == value.roundToDouble()) {
      return _intFr.format(value);
    }
    return NumberFormat('#,##0.##', 'fr_FR').format(value);
  }
}
