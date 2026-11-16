import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/core/widgets/app_network_image.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';

/// Image réseau d’un [Product] ou placeholder (icône) si URL absente / erreur.
class ProductImageBox extends StatelessWidget {
  const ProductImageBox({
    super.key,
    required this.product,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
  });

  final Product product;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final raw = product.imageUrl?.trim();
    final hasUrl = raw != null && raw.isNotEmpty;

    final h = height ?? 50;
    final iconSize = (h * 0.32).clamp(20.0, 40.0);

    Widget placeholder = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: HIcon(
          product.type == ProductType.service
              ? AppHugeIcons.wrench
              : AppHugeIcons.box,
          size: iconSize,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
        ),
      ),
    );

    Widget child;
    if (hasUrl) {
      final isNetworkImage =
          raw.startsWith('http://') || raw.startsWith('https://');
      if (isNetworkImage) {
        child = AppNetworkImage(
          imageUrl: raw,
          width: width,
          height: height,
          fit: fit,
          alignment: Alignment.center,
          // [placeholder] seul (pas de progressIndicatorBuilder) : parcours Octo
          // plus fiable qu’un suivi d’octets, évite le spinner perçu “infini”.
          placeholder: (context, url) {
            return ColoredBox(
              color: colorScheme.surfaceContainerHighest,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorWidget: (context, url, error) => placeholder,
        );
      } else {
        child = Image.file(
          File(raw),
          fit: fit,
          errorBuilder: (_, __, ___) => placeholder,
        );
      }
    } else {
      child = placeholder;
    }

    if (width != null || height != null) {
      child = SizedBox(
        width: width ?? (height != null ? double.infinity : null),
        height: height,
        child: child,
      );
    }

    if (borderRadius == BorderRadius.zero) {
      return child;
    }
    return ClipRRect(borderRadius: borderRadius, child: child);
  }
}
