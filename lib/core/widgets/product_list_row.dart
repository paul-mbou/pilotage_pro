import 'package:flutter/material.dart';

import 'package:pilotage_pro/domain/entities/entities.dart';
import 'package:pilotage_pro/core/widgets/product_image_box.dart';

/// Ligne de produit : vignette portrait (hauteur supérieure à la largeur) + contenu.
class ProductListRow extends StatelessWidget {
  const ProductListRow({
    super.key,
    required this.product,
    required this.onTap,
    required this.content,
  });

  final Product product;
  final VoidCallback onTap;
  final Widget content;

  static const double thumbWidth = 80;
  static const double thumbHeight = 80;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImageBox(
                product: product,
                width: thumbWidth,
                height: thumbHeight,
                borderRadius: BorderRadius.circular(10),
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 12),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }
}
