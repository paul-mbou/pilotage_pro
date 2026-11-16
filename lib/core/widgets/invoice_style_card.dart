import 'package:flutter/material.dart';

/// Même enveloppe visuelle que les cartes de [InvoiceListScreen] :
/// marge, surface, coins 12, padding 16, [InkWell] optionnel.
class InvoiceStyleCard extends StatelessWidget {
  const InvoiceStyleCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    const radius = 12.0;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: child,
    );

    return Card(
      margin: margin,
      elevation: 0,
      color: color,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(radius),
              child: content,
            )
          : content,
    );
  }
}
