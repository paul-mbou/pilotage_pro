import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/core/widgets/currency_text.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product =
        ref.watch(productProvider).firstWhere((p) => p.id == productId);
    final categories = ref.watch(categoryProvider);
    final movements = ref
        .watch(stockMovementProvider)
        .where((m) => m.productId == productId)
        .toList();
    final category = categories.firstWhere((c) => c.id == product.categoryId);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail produit'),
        actions: [
          IconButton(
            icon: HIcon(
              AppHugeIcons.edit,
              size: 22,
              color: colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const HIcon(
              AppHugeIcons.delete,
              size: 22,
              color: Colors.red,
            ),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: product.isLowStock
                            ? Colors.red.shade50
                            : colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: HIcon(
                        product.type == ProductType.service
                            ? AppHugeIcons.wrench
                            : AppHugeIcons.box,
                        size: 40,
                        color: product.isLowStock
                            ? Colors.red
                            : colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(category.name,
                        style: TextStyle(color: Colors.grey.shade600)),
                    if (product.barcode != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HIcon(AppHugeIcons.qr,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(product.barcode!,
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pricing Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informations tarifaires',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _InfoRow(
                        label: "Prix d'achat (PA)",
                        value: CurrencyText(
                          product.purchasePrice,
                          amountStyle:
                              const TextStyle(fontWeight: FontWeight.w600),
                        )),
                    const Divider(),
                    _InfoRow(
                        label: 'Prix de vente (PV)',
                        value: CurrencyText(
                          product.sellingPrice,
                          amountStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        )),
                    const Divider(),
                    if (product.minSellingPrice != null)
                      _InfoRow(
                        label: 'PV minimum',
                        value: CurrencyText(product.minSellingPrice!,
                            amountStyle:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    if (product.maxSellingPrice != null)
                      _InfoRow(
                        label: 'PV maximum',
                        value: CurrencyText(product.maxSellingPrice!,
                            amountStyle:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    const Divider(),
                    _InfoRow(
                      label: 'Marge unitaire',
                      value: CurrencyText(
                        product.margin,
                        amountStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    _InfoRow(
                        label: 'Taux de marge',
                        value: Text(
                          '${product.marginPercent.toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stock Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Stock',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        if (product.isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                HIcon(AppHugeIcons.warning,
                                    size: 14, color: Colors.red.shade700),
                                const SizedBox(width: 4),
                                Text('Stock faible',
                                    style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: 'Quantité actuelle',
                      value: Text(
                        '${product.quantity.toStringAsFixed(0)} ${product.unit}(s)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    _InfoRow(
                      label: 'Quantité de sécurité',
                      value: Text(
                        '${product.safetyStock.toStringAsFixed(0)} ${product.unit}(s)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Divider(),
                    _InfoRow(
                      label: 'Valeur stock (PA)',
                      value: CurrencyText(
                        product.stockValue,
                        amountStyle:
                            const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    _InfoRow(
                      label: 'Valeur stock (PV)',
                      value: CurrencyText(
                        product.stockValuePV,
                        amountStyle:
                            const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stock Movements
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Historique des mouvements',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    if (movements.isEmpty)
                      const Center(
                          child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Aucun mouvement')))
                    else
                      ...movements.take(10).map((m) => ListTile(
                            dense: true,
                            leading: HIcon(
                              m.type == MovementType.entree
                                  ? AppHugeIcons.stockIn
                                  : AppHugeIcons.stockOut,
                              size: 22,
                              color: m.type == MovementType.entree
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(
                                '${m.type.toString().split('.').last} • ${m.quantity.toStringAsFixed(0)} ${product.unit}(s)'),
                            subtitle: Text(dateFormat.format(m.date)),
                            trailing: Text(
                                '${m.previousQuantity.toStringAsFixed(0)} → ${m.newQuantity.toStringAsFixed(0)}'),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: HIcon(
          AppHugeIcons.delete,
          size: 32,
          color: colorScheme.error,
        ),
        title: const Text('Supprimer le produit ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(productProvider.notifier).deleteProduct(productId);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          value,
        ],
      ),
    );
  }
}
