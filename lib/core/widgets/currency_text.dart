import 'package:flutter/material.dart';

import 'package:pilotage_pro/core/app_currency.dart';
import 'package:pilotage_pro/core/theme_context.dart';

/// Montant + code devise [AppCurrency.code] : le code est affiché plus petit que les chiffres.
class CurrencyText extends StatelessWidget {
  const CurrencyText(
    this.amount, {
    super.key,
    this.amountStyle,
    this.currencyStyle,
    this.prefix,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final num amount;
  final TextStyle? amountStyle;
  final TextStyle? currencyStyle;
  final String? prefix;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  static const double _kCodeSizeFactor = 0.7;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final def = DefaultTextStyle.of(context).style;
    final base = def.merge(amountStyle);
    final fontSize = base.fontSize ?? 14.0;
    final cur = currencyStyle ??
        base.copyWith(
          fontSize: fontSize * _kCodeSizeFactor,
          fontWeight: FontWeight.w500,
          color: (base.color ?? scheme.onSurface).withValues(alpha: 0.75),
        );

    final n = amount.toDouble();
    final isNeg = n < 0;
    final absText = AppCurrency.formatNumber(n.abs());
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          if (prefix != null) TextSpan(text: prefix, style: base),
          if (isNeg) TextSpan(text: '−', style: base),
          TextSpan(text: absText, style: base),
          TextSpan(
            text: '\u00a0',
            style: base,
          ),
          TextSpan(text: AppCurrency.code, style: cur),
        ],
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
