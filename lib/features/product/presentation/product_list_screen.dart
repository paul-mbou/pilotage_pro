import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/core/utils/product_image_compression.dart';
import 'package:pilotage_pro/core/widgets/app_network_image.dart';
import 'package:pilotage_pro/core/widgets/category_filter_chip.dart';
import 'package:pilotage_pro/core/widgets/currency_text.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';
import 'package:pilotage_pro/core/widgets/product_list_row.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _showLowStockOnly = false;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final categories = ref.watch(categoryProvider);
    final colorScheme = context.colorScheme;

    var filteredProducts = products.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.barcode?.contains(_searchQuery) == true;
      final matchesCategory =
          _selectedCategoryId == null || p.categoryId == _selectedCategoryId;
      final matchesStock = !_showLowStockOnly || p.isLowStock;
      return matchesSearch && matchesCategory && matchesStock;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue produits'),
        actions: [
          IconButton(
            icon: HIcon(
              AppHugeIcons.addBox,
              size: 22,
              color: context.colorScheme.onSurface,
            ),
            tooltip: 'Nouvelle categorie',
            onPressed: () => _showCategoryForm(context),
          ),
          IconButton(
            icon: HIcon(
              AppHugeIcons.warning,
              size: 22,
              color: _showLowStockOnly
                  ? Colors.red
                  : context.colorScheme.onSurface,
            ),
            tooltip: 'Stock faible',
            onPressed: () =>
                setState(() => _showLowStockOnly = !_showLowStockOnly),
          ),
          IconButton(
            icon: HIcon(
              AppHugeIcons.add,
              size: 22,
              color: context.colorScheme.onSurface,
            ),
            onPressed: () => _showProductForm(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      maxWidth: 40,
                      minHeight: 40,
                      maxHeight: 40,
                    ),
                    prefixIcon: Align(
                      alignment: Alignment.center,
                      child: HIcon(
                        AppHugeIcons.search,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryFilterChip(
                          label: 'Tous',
                          selected: _selectedCategoryId == null,
                          colorScheme: colorScheme,
                          onSelected: () =>
                              setState(() => _selectedCategoryId = null),
                        ),
                      ),
                      ...categories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryFilterChip(
                            label: cat.name,
                            selected: _selectedCategoryId == cat.id,
                            colorScheme: colorScheme,
                            onSelected: () => setState(
                              () => _selectedCategoryId = cat.id,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('Aucun produit trouvé'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final categoryName = categories
                              .where((c) => c.id == product.categoryId)
                              .cast<Category?>()
                              .firstWhere(
                                (c) => c != null,
                                orElse: () => null,
                              )
                              ?.name ??
                          'Sans categorie';
                      return ProductListRow(
                        product: product,
                        onTap: () => context.push('/products/${product.id}'),
                        content: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$categoryName • '
                                    '${product.quantity.toStringAsFixed(0)} '
                                    '${product.unit}(s)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (product.barcode != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      product.barcode!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CurrencyText(
                                  product.sellingPrice,
                                  amountStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                CurrencyText(
                                  product.purchasePrice,
                                  prefix: 'PA: ',
                                  amountStyle: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showProductForm(BuildContext context, {Product? product}) {
    final categoriesNow = ref.read(categoryProvider);
    final nameController = TextEditingController(text: product?.name);
    final descController = TextEditingController(text: product?.description);
    final barcodeController = TextEditingController(text: product?.barcode);
    final paController =
        TextEditingController(text: product?.purchasePrice.toString());
    final pvController =
        TextEditingController(text: product?.sellingPrice.toString());
    final minController =
        TextEditingController(text: product?.minSellingPrice?.toString());
    final maxController =
        TextEditingController(text: product?.maxSellingPrice?.toString());
    final qtyController =
        TextEditingController(text: product?.quantity.toString());
    final safetyController =
        TextEditingController(text: product?.safetyStock.toString());
    final unitController =
        TextEditingController(text: product?.unit ?? 'unité');

    var categoryId = product?.categoryId ??
        (categoriesNow.isNotEmpty ? categoriesNow.first.id : '');
    final initialCategoryLabel = _categoryNameForId(categoriesNow, categoryId);
    final categorySearchController = TextEditingController(
      text: initialCategoryLabel ??
          (categoryId.isEmpty && categoriesNow.isNotEmpty
              ? categoriesNow.first.name
              : ''),
    );
    var showCategoryDropdown = false;
    ProductType type = product?.type ?? ProductType.produit;
    String locationId =
        product?.locationId ?? ref.read(selectedLocationProvider);
    String? selectedImagePath = product?.imageUrl;
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final categories = ref.watch(categoryProvider);
          return StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        product == null
                            ? 'Nouveau produit'
                            : 'Modifier produit',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          final compressed =
                              await compressProductImageFromDevice(
                            pickedFile.path,
                          );
                          if (context.mounted) {
                            setState(() => selectedImagePath = compressed);
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 150,
                        child: CustomPaint(
                          painter: _DashedRoundedRectPainter(
                            color: Colors.grey.shade400,
                            radius: 12,
                            strokeWidth: 1.5,
                            dashLength: 7,
                            gapLength: 4,
                          ),
                          child: selectedImagePath == null ||
                                  selectedImagePath!.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Ajouter une image (optionnel)',
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: selectedImagePath!
                                              .startsWith('http://') ||
                                          selectedImagePath!
                                              .startsWith('https://')
                                      ? AppNetworkImage(
                                          imageUrl: selectedImagePath!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(selectedImagePath!),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (selectedImagePath != null &&
                        selectedImagePath!.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              setState(() => selectedImagePath = null),
                          child: const Text('Retirer l’image'),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            labelText: 'Nom', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                        controller: barcodeController,
                        decoration: const InputDecoration(
                            labelText: 'Code-barres',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: paController,
                            decoration: const InputDecoration(
                              labelText: "Prix d'achat (PA)",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: TextField(
                                controller: pvController,
                                decoration: const InputDecoration(
                                    labelText: 'Prix de vente (PV)',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: TextField(
                                controller: minController,
                                decoration: const InputDecoration(
                                    labelText: 'PV min',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: TextField(
                                controller: maxController,
                                decoration: const InputDecoration(
                                    labelText: 'PV max',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: TextField(
                                controller: qtyController,
                                decoration: const InputDecoration(
                                    labelText: 'Quantité',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: TextField(
                                controller: safetyController,
                                decoration: const InputDecoration(
                                    labelText: 'Qté sécurité',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                        controller: unitController,
                        decoration: const InputDecoration(
                            labelText: 'Unité', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categorySearchController,
                      onTap: () => setState(() => showCategoryDropdown = true),
                      decoration: InputDecoration(
                        labelText: 'Catégorie',
                        hintText: 'Rechercher ou créer…',
                        border: const OutlineInputBorder(),
                        suffixIcon: categorySearchController.text.isNotEmpty ||
                                categoryId.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                tooltip: 'Effacer',
                                onPressed: () {
                                  setState(() {
                                    categoryId = '';
                                    categorySearchController.clear();
                                    showCategoryDropdown = true;
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) =>
                          setState(() => showCategoryDropdown = true),
                    ),
                    if (showCategoryDropdown) ...[
                      const SizedBox(height: 6),
                      Builder(
                        builder: (_) {
                          final filtered = _filteredCategories(
                            categories,
                            categorySearchController.text,
                          );
                          final visibleItems = filtered.take(6).toList();
                          final dropdownChildren = <Widget>[];
                          for (var i = 0; i < visibleItems.length; i++) {
                            final c = visibleItems[i];
                            dropdownChildren.add(
                              ListTile(
                                dense: true,
                                title: Text(c.name),
                                onTap: () {
                                  setState(() {
                                    categoryId = c.id;
                                    categorySearchController.text = c.name;
                                    showCategoryDropdown = false;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            );
                            if (i < visibleItems.length - 1) {
                              dropdownChildren.add(const Divider(height: 1));
                            }
                          }
                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 264),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Material(
                                  color: Theme.of(context).colorScheme.surface,
                                  child: ListView(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    children: [
                                      ...dropdownChildren,
                                      if (_canCreateCategory(categories,
                                          categorySearchController.text))
                                        if (dropdownChildren.isNotEmpty)
                                          const Divider(height: 1),
                                      if (_canCreateCategory(categories,
                                          categorySearchController.text))
                                        ListTile(
                                          dense: true,
                                          leading: Icon(
                                            Icons.add_circle_outline,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          title: Text(
                                            'Créer « ${categorySearchController.text.trim()} »',
                                          ),
                                          onTap: () {
                                            final name =
                                                categorySearchController.text
                                                    .trim();
                                            final created =
                                                Category(name: name);
                                            ref
                                                .read(categoryProvider.notifier)
                                                .add(created);
                                            setState(() {
                                              categoryId = created.id;
                                              categorySearchController.text =
                                                  created.name;
                                              showCategoryDropdown = false;
                                            });
                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    SegmentedButton<ProductType>(
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.18);
                          }
                          return Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.25);
                        }),
                        foregroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Theme.of(context).colorScheme.onSurface;
                          }
                          return Theme.of(context).colorScheme.onSurfaceVariant;
                        }),
                      ),
                      segments: const [
                        ButtonSegment(
                            value: ProductType.produit, label: Text('Produit')),
                        ButtonSegment(
                            value: ProductType.service, label: Text('Service')),
                      ],
                      selected: {type},
                      onSelectionChanged: (v) => setState(() => type = v.first),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          var resolvedCategoryId = categoryId;
                          if (resolvedCategoryId.isEmpty) {
                            final q = categorySearchController.text.trim();
                            final exact = categories
                                .where(
                                  (c) =>
                                      c.name.toLowerCase() == q.toLowerCase(),
                                )
                                .toList();
                            if (exact.length == 1) {
                              resolvedCategoryId = exact.single.id;
                            }
                          }
                          if (resolvedCategoryId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Choisissez une catégorie ou créez-en une.',
                                ),
                              ),
                            );
                            return;
                          }
                          final newProduct = Product(
                            id: product?.id,
                            name: nameController.text,
                            imageUrl: selectedImagePath?.trim().isEmpty ?? true
                                ? null
                                : selectedImagePath!.trim(),
                            description: descController.text.isEmpty
                                ? null
                                : descController.text,
                            barcode: barcodeController.text.isEmpty
                                ? null
                                : barcodeController.text,
                            type: type,
                            categoryId: resolvedCategoryId,
                            purchasePrice:
                                double.tryParse(paController.text) ?? 0,
                            sellingPrice:
                                double.tryParse(pvController.text) ?? 0,
                            minSellingPrice:
                                double.tryParse(minController.text),
                            maxSellingPrice:
                                double.tryParse(maxController.text),
                            quantity: double.tryParse(qtyController.text) ?? 0,
                            safetyStock:
                                double.tryParse(safetyController.text) ?? 0,
                            unit: unitController.text,
                            locationId: locationId,
                          );
                          if (product == null) {
                            ref
                                .read(productProvider.notifier)
                                .addProduct(newProduct);
                          } else {
                            ref
                                .read(productProvider.notifier)
                                .updateProduct(newProduct);
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                        child:
                            Text(product == null ? 'CRÉER' : 'METTRE À JOUR'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String? _categoryNameForId(List<Category> cats, String id) {
    if (id.isEmpty) return null;
    for (final c in cats) {
      if (c.id == id) return c.name;
    }
    return null;
  }

  static List<Category> _filteredCategories(
    List<Category> all,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  static bool _canCreateCategory(List<Category> all, String query) {
    final t = query.trim();
    if (t.isEmpty) return false;
    final lower = t.toLowerCase();
    return !all.any((c) => c.name.toLowerCase() == lower);
  }

  void _showCategoryForm(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle categorie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                return;
              }
              ref.read(categoryProvider.notifier).add(
                    Category(
                      name: name,
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                    ),
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Categorie ajoutee')),
              );
            },
            child: const Text('Creer'),
          ),
        ],
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  _DashedRoundedRectPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = math.min(distance + dashLength, metric.length);
        final segment = metric.extractPath(distance, nextDistance);
        canvas.drawPath(segment, paint);
        distance = nextDistance + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}
