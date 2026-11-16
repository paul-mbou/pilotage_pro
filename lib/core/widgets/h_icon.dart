import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Raccourci [HugeIcon] (stroke rounded) — thème si [color] est null.
/// Voir [hugeicons](https://pub.dev/packages/hugeicons) et
/// [Flutter integration](https://hugeicons.com/docs/integrations/flutter).
class HIcon extends StatelessWidget {
  const HIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 1.5,
  });

  final List<List<dynamic>> icon;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return HugeIcon(
      icon: icon,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}
