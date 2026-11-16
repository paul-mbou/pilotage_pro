import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';

class StockMovementScreen extends ConsumerStatefulWidget {
  const StockMovementScreen({super.key});

  @override
  ConsumerState<StockMovementScreen> createState() =>
      _StockMovementScreenState();
}

class _StockMovementScreenState extends ConsumerState<StockMovementScreen> {
  MovementType _selectedType = MovementType.transfert;
  String? _selectedProductId;
  String? _sourceLocationId;
  String? _destLocationId;
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsByLocationProvider);
    final locations = ref.watch(locationProvider);
    final movements = ref.watch(stockMovementProvider);
    final currentUser = ref.watch(currentUserProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Mouvements de stock')),
      body: Column(
        children: [
          // New Movement Form
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nouveau mouvement',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SegmentedButton<MovementType>(
                    segments: const [
                      ButtonSegment(
                          value: MovementType.transfert,
                          label: Text('Transfert')),
                      ButtonSegment(
                          value: MovementType.ajustement,
                          label: Text('Ajustement')),
                      ButtonSegment(
                          value: MovementType.sortie, label: Text('Sortie')),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (v) =>
                        setState(() => _selectedType = v.first),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: 'Produit', border: OutlineInputBorder()),
                    initialValue: _selectedProductId,
                    items: products
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedProductId = v),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedType == MovementType.transfert) ...[
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Source',
                                border: OutlineInputBorder()),
                            initialValue: _sourceLocationId,
                            items: locations
                                .map(
                                  (l) => DropdownMenuItem(
                                    value: l.id,
                                    child: Text(
                                      l.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _sourceLocationId = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Destination',
                                border: OutlineInputBorder()),
                            initialValue: _destLocationId,
                            items: locations
                                .map(
                                  (l) => DropdownMenuItem(
                                    value: l.id,
                                    child: Text(
                                      l.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _destLocationId = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                        labelText: 'Quantité', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                        labelText: 'Motif', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedProductId == null
                          ? null
                          : () => _saveMovement(products, currentUser),
                      child: const Text('ENREGISTRER LE MOUVEMENT'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Movement History
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Historique',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          Expanded(
            child: movements.isEmpty
                ? const Center(child: Text('Aucun mouvement'))
                : ListView.builder(
                    itemCount: movements.length,
                    itemBuilder: (context, index) {
                      final m = movements[index];
                      final product = products.firstWhere(
                          (p) => p.id == m.productId,
                          orElse: () => Product(
                              id: '',
                              name: 'Inconnu',
                              categoryId: '',
                              purchasePrice: 0,
                              sellingPrice: 0,
                              type: ProductType.produit));
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _getTypeColor(m.type).withOpacity(0.1),
                            child: HIcon(
                              _getTypeIcon(m.type),
                              size: 22,
                              color: _getTypeColor(m.type),
                            ),
                          ),
                          title: Text(product.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(
                              '${m.type.toString().split('.').last} • ${dateFormat.format(m.date)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  '${m.quantity > 0 ? '+' : ''}${m.quantity.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getTypeColor(m.type))),
                              Text(
                                  '${m.previousQuantity.toStringAsFixed(0)} → ${m.newQuantity.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(MovementType type) {
    switch (type) {
      case MovementType.entree:
        return Colors.green;
      case MovementType.sortie:
        return Colors.red;
      case MovementType.transfert:
        return Colors.blue;
      case MovementType.ajustement:
        return Colors.orange;
    }
  }

  List<List<dynamic>> _getTypeIcon(MovementType type) {
    switch (type) {
      case MovementType.entree:
        return AppHugeIcons.stockIn;
      case MovementType.sortie:
        return AppHugeIcons.stockOut;
      case MovementType.transfert:
        return AppHugeIcons.transfer;
      case MovementType.ajustement:
        return AppHugeIcons.adjust;
    }
  }

  void _saveMovement(List<Product> products, User? user) {
    final product = products.firstWhere((p) => p.id == _selectedProductId);
    final qty = double.tryParse(_quantityController.text) ?? 0;
    double newQty = product.quantity;

    switch (_selectedType) {
      case MovementType.entree:
        newQty += qty;
        break;
      case MovementType.sortie:
        newQty -= qty;
        break;
      case MovementType.transfert:
        newQty -= qty;
        break;
      case MovementType.ajustement:
        newQty = qty;
        break;
    }

    ref
        .read(productProvider.notifier)
        .updateQuantity(_selectedProductId!, newQty);
    ref.read(stockMovementProvider.notifier).add(StockMovement(
          productId: _selectedProductId!,
          type: _selectedType,
          quantity: qty,
          previousQuantity: product.quantity,
          newQuantity: newQty,
          userId: user?.id ?? 'unknown',
          reason: _reasonController.text,
          sourceLocationId: _sourceLocationId,
          destinationLocationId: _destLocationId,
        ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Mouvement enregistré'), backgroundColor: Colors.green),
    );

    setState(() {
      _quantityController.clear();
      _reasonController.clear();
      _selectedProductId = null;
    });
  }
}
