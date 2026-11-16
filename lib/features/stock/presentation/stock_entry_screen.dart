import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/core/widgets/currency_text.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';

class StockEntryScreen extends ConsumerStatefulWidget {
  const StockEntryScreen({super.key});

  @override
  ConsumerState<StockEntryScreen> createState() => _StockEntryScreenState();
}

class _StockEntryScreenState extends ConsumerState<StockEntryScreen> {
  final List<_EntryLine> _lines = [];
  final _referenceController = TextEditingController();
  final _reasonController = TextEditingController(text: 'Mise en stock');

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsByLocationProvider);
    final currentUser = ref.watch(currentUserProvider);

    double totalValue = 0;
    for (final line in _lines) {
      final product = products.firstWhere((p) => p.id == line.productId);
      totalValue += product.purchasePrice * line.quantity;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mise en stock'),
        actions: [
          if (_lines.isNotEmpty)
            TextButton(
              onPressed: () => _saveEntry(context, products, currentUser),
              child:
                  const Text('VALIDER', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                      labelText: 'Référence (optionnel)',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                      labelText: 'Motif', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _lines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HIcon(
                          AppHugeIcons.addBox,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text('Ajoutez des produits',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _lines.length,
                    itemBuilder: (context, index) {
                      final line = _lines[index];
                      final product =
                          products.firstWhere((p) => p.id == line.productId);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: CurrencyText(
                            product.purchasePrice,
                            prefix: 'PA: ',
                            amountStyle: TextStyle(
                              fontSize: 13,
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  decoration:
                                      const InputDecoration(suffixText: 'qty'),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: TextEditingController(
                                      text: line.quantity.toString()),
                                  onChanged: (v) => setState(() =>
                                      line.quantity = double.tryParse(v) ?? 0),
                                ),
                              ),
                              IconButton(
                                icon: const HIcon(
                                  AppHugeIcons.delete,
                                  size: 22,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    setState(() => _lines.removeAt(index)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_lines.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CurrencyText(
                      totalValue,
                      prefix: 'Total: ',
                      amountStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text('${_lines.length} produit(s)'),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context, products),
        icon: HIcon(
          AppHugeIcons.add,
          size: 24,
          color: context.colorScheme.onPrimary,
        ),
        label: const Text('Ajouter'),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, List<Product> products) {
    String? selectedProductId;
    final qtyController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un produit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'Produit', border: OutlineInputBorder()),
              items: products
                  .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                  .toList(),
              onChanged: (v) => selectedProductId = v,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(
                  labelText: 'Quantité', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              if (selectedProductId != null) {
                setState(() => _lines.add(_EntryLine(
                      productId: selectedProductId!,
                      quantity: double.tryParse(qtyController.text) ?? 1,
                    )));
              }
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _saveEntry(BuildContext context, List<Product> products, User? user) {
    for (final line in _lines) {
      final product = products.firstWhere((p) => p.id == line.productId);
      final newQty = product.quantity + line.quantity;

      ref.read(productProvider.notifier).updateQuantity(line.productId, newQty);
      ref.read(stockMovementProvider.notifier).add(StockMovement(
            productId: line.productId,
            type: MovementType.entree,
            quantity: line.quantity,
            previousQuantity: product.quantity,
            newQuantity: newQty,
            userId: user?.id ?? 'unknown',
            reason: _reasonController.text,
            reference: _referenceController.text.isEmpty
                ? null
                : _referenceController.text,
          ));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Mise en stock effectuée avec succès'),
          backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }
}

class _EntryLine {
  String productId;
  double quantity;
  _EntryLine({required this.productId, required this.quantity});
}
