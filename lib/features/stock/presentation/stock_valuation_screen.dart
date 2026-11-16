import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/core/widgets/currency_text.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';

class StockValuationScreen extends ConsumerWidget {
  const StockValuationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsByLocationProvider);
    final totalPA = products.fold(0.0, (sum, p) => sum + p.stockValue);
    final totalPV = products.fold(0.0, (sum, p) => sum + p.stockValuePV);
    final totalMargin = totalPV - totalPA;
    final marginPercent = totalPA > 0 ? (totalMargin / totalPA) * 100 : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Valorisation du stock')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _ValuationCard(
                    title: "Valeur d'achat (PA)",
                    value: CurrencyText(
                      totalPA,
                      amountStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    color: Colors.blue,
                    icon: AppHugeIcons.shoppingCart,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ValuationCard(
                    title: 'Valeur de vente (PV)',
                    value: CurrencyText(
                      totalPV,
                      amountStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    color: Colors.green,
                    icon: AppHugeIcons.tagSell,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ValuationCard(
              title: 'Marge prévisionnelle',
              value: CurrencyText(
                totalMargin,
                amountStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              subtitle: '${marginPercent.toStringAsFixed(1)}% de marge',
              color: Colors.purple,
              icon: AppHugeIcons.chartLine,
              fullWidth: true,
            ),
            const SizedBox(height: 24),

            // Products Detail Table
            const Text('Détail par produit',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Produit')),
                    DataColumn(label: Text('Qté'), numeric: true),
                    DataColumn(label: Text('PA unit'), numeric: true),
                    DataColumn(label: Text('PV unit'), numeric: true),
                    DataColumn(label: Text('Valeur PA'), numeric: true),
                    DataColumn(label: Text('Valeur PV'), numeric: true),
                    DataColumn(label: Text('Marge'), numeric: true),
                  ],
                  rows: products
                      .map((p) => DataRow(
                            cells: [
                              DataCell(Text(p.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500))),
                              DataCell(Text(p.quantity.toStringAsFixed(0))),
                              DataCell(Align(
                                alignment: Alignment.centerRight,
                                child: CurrencyText(
                                  p.purchasePrice,
                                  amountStyle: const TextStyle(fontSize: 13),
                                ),
                              )),
                              DataCell(Align(
                                alignment: Alignment.centerRight,
                                child: CurrencyText(
                                  p.sellingPrice,
                                  amountStyle: const TextStyle(fontSize: 13),
                                ),
                              )),
                              DataCell(Align(
                                alignment: Alignment.centerRight,
                                child: CurrencyText(
                                  p.stockValue,
                                  amountStyle: const TextStyle(fontSize: 13),
                                ),
                              )),
                              DataCell(Align(
                                alignment: Alignment.centerRight,
                                child: CurrencyText(
                                  p.stockValuePV,
                                  amountStyle: const TextStyle(fontSize: 13),
                                ),
                              )),
                              DataCell(Align(
                                alignment: Alignment.centerRight,
                                child: CurrencyText(
                                  p.margin * p.quantity,
                                  amountStyle: TextStyle(
                                    color: p.margin > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              )),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category Breakdown
            const Text('Répartition par catégorie',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...ref.watch(categoryProvider).map((cat) {
              final catProducts = products.where((p) => p.categoryId == cat.id);
              final catValue =
                  catProducts.fold(0.0, (sum, p) => sum + p.stockValuePV);
              final catQty =
                  catProducts.fold(0.0, (sum, p) => sum + p.quantity);
              if (catQty == 0) return const SizedBox.shrink();
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: context.colorScheme.primaryContainer,
                      child: Text(cat.name.substring(0, 1))),
                  title: Text(cat.name),
                  subtitle: Text('${catQty.toStringAsFixed(0)} article(s)'),
                  trailing: CurrencyText(
                    catValue,
                    amountStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ValuationCard extends StatelessWidget {
  const _ValuationCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.color,
    required this.icon,
    this.fullWidth = false,
  });

  final String title;
  final Widget value;
  final String? subtitle;
  final Color color;
  final List<List<dynamic>> icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: HIcon(icon, color: color, size: 20),
                ),
                if (fullWidth) ...[
                  const Spacer(),
                  value,
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (!fullWidth) value,
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!,
                  style: TextStyle(
                      color: color.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}
