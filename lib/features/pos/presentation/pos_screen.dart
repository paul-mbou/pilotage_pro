import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/core/view_context.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/core/theme/design_tokens.dart';
import 'package:pilotage_pro/core/widgets/category_filter_chip.dart';
import 'package:pilotage_pro/core/widgets/currency_text.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';
import 'package:pilotage_pro/core/widgets/invoice_style_card.dart';
import 'package:pilotage_pro/core/widgets/product_list_row.dart';

/// Point de vente (caisse) : recherche, filtres par catégorie, liste produits,
/// panier en tiroir, SnackBar à l’ajout, paiement et mise à jour stock / facture.
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

/// État de [PosScreen] : recherche, catégorie active, [Scaffold] (tiroir panier).
class _PosScreenState extends ConsumerState<PosScreen> {
  // --- Recherche & filtres ---
  String _searchQuery = '';
  String? _selectedCategoryId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Nombre d’unités affiché sur le badge AppBar (somme des quantités).
  int _cartUnitCount(List<InvoiceItem> cart) =>
      cart.fold(0, (a, b) => a + b.quantity.round());

  // --- UI : barre d’app (ouverture panier), zone recherche + chips, liste ---
  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsByLocationProvider);
    final categories = ref.watch(categoryProvider);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final filteredProducts = products.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.barcode?.contains(_searchQuery) == true;
      final matchesCategory =
          _selectedCategoryId == null || p.categoryId == _selectedCategoryId;
      return matchesSearch && matchesCategory && p.type == ProductType.produit;
    }).toList();

    final cartTotal = cart.fold(0.0, (sum, item) => sum + item.total);
    final unitCount = _cartUnitCount(cart);

    final colorScheme = context.colorScheme;
    final onSurface = colorScheme.onSurfaceVariant;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _PosCartDrawer(
        cart: cart,
        cartTotal: cartTotal,
        unitCount: unitCount,
        onClose: () => _scaffoldKey.currentState?.closeEndDrawer(),
        onDecrement: (id, currentQty) {
          if (currentQty <= 1) {
            cartNotifier.removeItem(id);
          } else {
            cartNotifier.updateQuantity(id, currentQty - 1);
          }
        },
        onIncrement: (id, currentQty) {
          cartNotifier.updateQuantity(id, currentQty + 1);
        },
        onSetQuantity: (id, newQty) {
          if (newQty <= 0) {
            cartNotifier.removeItem(id);
          } else {
            cartNotifier.updateQuantity(id, newQty);
          }
        },
        onRemoveLine: (id) => cartNotifier.removeItem(id),
        onClear: () {
          _showClearCartDialog(
            context,
            cartNotifier,
            onCleared: () {
              if (context.mounted) {
                _scaffoldKey.currentState?.closeEndDrawer();
              }
            },
          );
        },
        onPay: _openPaymentSheet,
      ),
      appBar: AppBar(
        title: const Text('Caisse - Point de vente'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: unitCount > 0,
              label: Text('$unitCount', style: const TextStyle(fontSize: 11)),
              child: HIcon(
                AppHugeIcons.shoppingCart,
                size: 24,
                color: context.colorScheme.onSurface,
              ),
            ),
            tooltip: 'Panier',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
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
                    hintText: 'Rechercher un produit...',
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
                        color: onSurface,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: HIcon(
                        AppHugeIcons.barcode,
                        size: 20,
                        color: context.colorScheme.onSurface,
                      ),
                      onPressed: () => _simulateScan(context, products),
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
                            onSelected: () =>
                                setState(() => _selectedCategoryId = cat.id),
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
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _PosProductListRow(
                        product: product,
                        onTap: () => _addProductToCart(product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Panier : ajout depuis la liste + SnackBar (action « Voir le panier ») ---

  void _addProductToCart(Product product) {
    ref.read(cartProvider.notifier).addItem(product);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('« ${product.name} » ajouté au panier'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Voir le panier',
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
        ),
      ),
    );
  }

  // --- Paiement : depuis le tiroir → bottom sheet → facture + stock ---

  void _openPaymentSheet() {
    _scaffoldKey.currentState?.closeEndDrawer();
    final lines = List<InvoiceItem>.from(ref.read(cartProvider));
    if (lines.isEmpty) return;
    final total = lines.fold(0.0, (double a, InvoiceItem b) => a + b.total);
    final user = ref.read(currentUserProvider);
    final locationId = ref.read(selectedLocationProvider);
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _showPaymentDialog(
        context,
        lines,
        total,
        user,
        locationId,
      );
    });
  }

  // --- Scan simulé : choix d’un produit à code-barres pour alimenter le panier ---

  void _simulateScan(BuildContext context, List<Product> products) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan de code-barres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HIcon(AppHugeIcons.barcode, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Simulation de scan...'),
            const SizedBox(height: 16),
            ...products
                .where((p) => p.barcode != null)
                .take(3)
                .map((p) => ListTile(
                      title: Text(p.name),
                      subtitle: Text(p.barcode!),
                      onTap: () {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) _addProductToCart(p);
                        });
                      },
                    )),
          ],
        ),
      ),
    );
  }

  // --- Dialogue : confirmation avant de vider le panier ---

  void _showClearCartDialog(
    BuildContext context,
    CartNotifier notifier, {
    VoidCallback? onCleared,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vider le panier ?'),
        content: const Text('Tous les articles seront supprimés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              notifier.clear();
              Navigator.pop(dialogContext);
              onCleared?.call();
            },
            child: const Text('Vider', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- Bottom sheet : montant, mode de paiement, crédit, validation vente ---

  void _showPaymentDialog(BuildContext context, List<InvoiceItem> cart,
      double total, User? user, String locationId) {
    PaymentMethod selectedMethod = PaymentMethod.espece;
    bool isCredit = false;
    double amountPaid = total;
    String? customerName;
    String? customerPhone;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final colorScheme = context.colorScheme;
          final onSurface = colorScheme.onSurface;
          final onSurfaceVar = colorScheme.onSurfaceVariant;
          // Total, chips mode de paiement, champs crédit, bouton valider.
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: onSurfaceVar.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Paiement',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(4),
                          minimumSize: const Size(40, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: onSurfaceVar,
                        ),
                        tooltip: 'Fermer',
                        icon: HIcon(
                          AppHugeIcons.cancel,
                          size: 22,
                          color: onSurfaceVar,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Total à payer',
                    style: TextStyle(color: onSurfaceVar),
                  ),
                  CurrencyText(
                    total,
                    amountStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mode de paiement',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _PaymentMethodChip(
                        label: 'Espèces',
                        selected: selectedMethod == PaymentMethod.espece,
                        onTap: () => setState(() {
                          selectedMethod = PaymentMethod.espece;
                          isCredit = false;
                        }),
                      ),
                      _PaymentMethodChip(
                        label: 'Carte',
                        selected: selectedMethod == PaymentMethod.carte,
                        onTap: () => setState(() {
                          selectedMethod = PaymentMethod.carte;
                          isCredit = false;
                        }),
                      ),
                      _PaymentMethodChip(
                        label: 'Mobile Money',
                        selected: selectedMethod == PaymentMethod.mobile,
                        onTap: () => setState(() {
                          selectedMethod = PaymentMethod.mobile;
                          isCredit = false;
                        }),
                      ),
                      _PaymentMethodChip(
                        label: 'Crédit',
                        selected: selectedMethod == PaymentMethod.credit,
                        onTap: () => setState(() {
                          selectedMethod = PaymentMethod.credit;
                          isCredit = true;
                        }),
                      ),
                    ],
                  ),
                  if (isCredit) ...[
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nom du client',
                        border: const OutlineInputBorder(),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 44,
                          maxWidth: 44,
                          minHeight: 40,
                          maxHeight: 40,
                        ),
                        prefixIcon: Center(
                          child: HIcon(
                            AppHugeIcons.user,
                            size: 20,
                            color: onSurfaceVar,
                          ),
                        ),
                      ),
                      onChanged: (v) => customerName = v,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Téléphone',
                        border: const OutlineInputBorder(),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 44,
                          maxWidth: 44,
                          minHeight: 40,
                          maxHeight: 40,
                        ),
                        prefixIcon: Center(
                          child: HIcon(
                            AppHugeIcons.smartphone,
                            size: 20,
                            color: onSurfaceVar,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => customerPhone = v,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Montant payé',
                        border: const OutlineInputBorder(),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 44,
                          maxWidth: 44,
                          minHeight: 40,
                          maxHeight: 40,
                        ),
                        prefixIcon: Center(
                          child: HIcon(
                            AppHugeIcons.money,
                            size: 20,
                            color: onSurfaceVar,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => amountPaid = double.tryParse(v) ?? 0,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final invoice = Invoice(
                          items: List.from(cart),
                          paymentMethod: selectedMethod,
                          cashierId: user?.id ?? 'unknown',
                          cashierName: user?.name ?? 'Inconnu',
                          locationId: locationId,
                          customerName: customerName,
                          customerPhone: customerPhone,
                          isCredit: isCredit,
                          amountPaid: isCredit ? amountPaid : total,
                          status: isCredit && amountPaid < total
                              ? InvoiceStatus.enAttente
                              : InvoiceStatus.payee,
                        );
                        ref.read(invoiceProvider.notifier).addInvoice(invoice);
                        ref.read(cartProvider.notifier).clear();

                        // Update stock
                        for (final item in cart) {
                          final product = ref
                              .read(productProvider)
                              .firstWhere((p) => p.id == item.productId);
                          ref.read(productProvider.notifier).updateQuantity(
                                item.productId,
                                product.quantity - item.quantity,
                              );
                          ref
                              .read(stockMovementProvider.notifier)
                              .add(StockMovement(
                                productId: item.productId,
                                type: MovementType.sortie,
                                quantity: item.quantity,
                                previousQuantity: product.quantity,
                                newQuantity: product.quantity - item.quantity,
                                userId: user?.id ?? 'unknown',
                                reason: 'Vente',
                                reference: invoice.invoiceNumber,
                              ));
                        }

                        Navigator.pop(context);
                        _showSuccessDialog(context, invoice.invoiceNumber);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('VALIDER LE PAIEMENT',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Alerte : paiement enregistré (numéro de facture) ---

  void _showSuccessDialog(BuildContext context, String invoiceNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const HIcon(
          AppHugeIcons.success,
          size: 64,
          color: Colors.green,
        ),
        title: const Text('Paiement réussi !'),
        content: Text('Facture $invoiceNumber enregistrée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tiroir panier (end drawer) : largeur partielle, lignes, total, vider, payer.
// ---------------------------------------------------------------------------

class _PosCartDrawer extends StatelessWidget {
  const _PosCartDrawer({
    required this.cart,
    required this.cartTotal,
    required this.unitCount,
    required this.onClose,
    required this.onDecrement,
    required this.onIncrement,
    required this.onSetQuantity,
    required this.onRemoveLine,
    required this.onClear,
    required this.onPay,
  });

  final List<InvoiceItem> cart;
  final double cartTotal;
  final int unitCount;
  final VoidCallback onClose;
  final void Function(String productId, double currentQty) onDecrement;
  final void Function(String productId, double currentQty) onIncrement;

  /// Saisie clavier : [newQty] ≤ 0 retire la ligne.
  final void Function(String productId, double newQty) onSetQuantity;
  final void Function(String productId) onRemoveLine;
  final VoidCallback onClear;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final onVar = colorScheme.onSurfaceVariant;
    final w = context.viewWidth * 0.8;
    final borderSide = colorScheme.outline.withValues(alpha: 0.12);

    return Drawer(
      width: w,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderSide),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête : icône, titre « Panier », pastille (articles / lignes), fermer
          SafeArea(
            bottom: false,
            child: Material(
              color:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  StocklyLayout.spaceMd,
                  12,
                  4,
                  StocklyLayout.spaceMd,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            colorScheme.primaryContainer.withValues(alpha: 0.6),
                        borderRadius:
                            BorderRadius.circular(StocklyLayout.radiusMd),
                      ),
                      child: Center(
                        child: HIcon(
                          AppHugeIcons.shoppingCart,
                          size: 24,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Panier',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (unitCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  StocklyLayout.radiusSm,
                                ),
                                border: Border.all(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.22),
                                ),
                              ),
                              child: Text(
                                '$unitCount article'
                                '${unitCount > 1 ? 's' : ''} · '
                                '${cart.length} ligne${cart.length > 1 ? 's' : ''}',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            )
                          else
                            Text(
                              'Aucun article',
                              style: textTheme.labelMedium?.copyWith(
                                color: onVar,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      style: IconButton.styleFrom(
                        foregroundColor: onVar,
                      ),
                      icon: HIcon(
                        AppHugeIcons.cancel,
                        size: 22,
                        color: onVar,
                      ),
                      tooltip: 'Fermer',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          // Zone centrale : message vide ou liste des [InvoiceItem] (cartes)
          Expanded(
            child: cart.isEmpty
                ? _CartDrawerEmptyState(onVar: onVar, textTheme: textTheme)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: StocklyLayout.spaceSm,
                      vertical: StocklyLayout.spaceMd,
                    ),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => const SizedBox(
                      height: StocklyLayout.spaceSm,
                    ),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return InvoiceStyleCard(
                        margin: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Ligne 1 : libellé + retirer
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.productName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () => onRemoveLine(item.productId),
                                  style: IconButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.all(4),
                                    minimumSize: const Size(32, 32),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    foregroundColor: colorScheme.error,
                                  ),
                                  icon: HIcon(
                                    AppHugeIcons.removeCircle,
                                    size: 20,
                                    color: colorScheme.error,
                                  ),
                                  tooltip: 'Retirer',
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color:
                                    colorScheme.outline.withValues(alpha: 0.12),
                              ),
                            ),
                            // Ligne 2 : prix unitaire | montant ligne
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Prix unitaire',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: onVar,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      CurrencyText(
                                        item.unitPrice,
                                        amountStyle:
                                            textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Montant ligne',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: onVar,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    CurrencyText(
                                      item.total,
                                      amountStyle:
                                          textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.25,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Ligne 3 : ajustement quantité
                            Text(
                              'Quantité',
                              style: textTheme.labelSmall?.copyWith(
                                color: onVar,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(
                                  StocklyLayout.radiusSm,
                                ),
                                border: Border.all(
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.18),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    _QtyChip(
                                      label: '−',
                                      embedded: true,
                                      isPrimary: false,
                                      onTap: () => onDecrement(
                                        item.productId,
                                        item.quantity,
                                      ),
                                    ),
                                    const Spacer(),
                                    Flexible(
                                      flex: 2,
                                      child: Center(
                                        child: _CartLineQuantityField(
                                          key: ValueKey<String>(item.productId),
                                          productId: item.productId,
                                          quantity: item.quantity,
                                          style:
                                              textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: colorScheme.onSurface,
                                          ),
                                          onCommit: onSetQuantity,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    _QtyChip(
                                      label: '+',
                                      embedded: true,
                                      isPrimary: true,
                                      onTap: () => onIncrement(
                                        item.productId,
                                        item.quantity,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (cart.isNotEmpty) ...[
            // Récapitulatif : total TTC avant les boutons
            Divider(
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                0,
                0,
                StocklyLayout.spaceSm,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color:
                        colorScheme.primaryContainer.withValues(alpha: 0.28)),
                child: Padding(
                  padding: const EdgeInsets.all(StocklyLayout.spaceMd),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total TTC',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.9),
                        ),
                      ),
                      CurrencyText(
                        cartTotal,
                        amountStyle: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          // Pied : vider le panier + PAYER (désactivé si panier vide)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                StocklyLayout.spaceSm,
                0,
                StocklyLayout.spaceSm,
                StocklyLayout.spaceMd,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onClear,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(
                          color: colorScheme.error.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            StocklyLayout.radiusMd,
                          ),
                        ),
                      ),
                      icon: HIcon(
                        AppHugeIcons.delete,
                        size: 18,
                        color: colorScheme.error,
                      ),
                      label: const Text('Vider le panier'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: cart.isEmpty ? null : onPay,
                      style: FilledButton.styleFrom(
                        backgroundColor: StocklyPalette.success,
                        foregroundColor: StocklyPalette.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            StocklyLayout.radiusMd,
                          ),
                        ),
                        elevation: 0,
                      ),
                      icon: const HIcon(
                        AppHugeIcons.pos,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: const Text('PAYER'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Saisie directe de la quantité (clavier) au centre de la barre [−] / [+].
class _CartLineQuantityField extends StatefulWidget {
  const _CartLineQuantityField({
    super.key,
    required this.productId,
    required this.quantity,
    required this.style,
    required this.onCommit,
  });

  final String productId;
  final double quantity;
  final TextStyle? style;
  final void Function(String productId, double newQuantity) onCommit;

  @override
  State<_CartLineQuantityField> createState() => _CartLineQuantityFieldState();
}

class _CartLineQuantityFieldState extends State<_CartLineQuantityField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  static String _formatQuantity(double q) {
    if (q % 1 == 0) {
      return q.toStringAsFixed(0);
    }
    return q.toStringAsFixed(1);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatQuantity(widget.quantity),
    );
    _focus = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      _applyCommit();
    }
  }

  void _applyCommit() {
    final raw = _controller.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) {
      _controller.text = _formatQuantity(widget.quantity);
      return;
    }
    final parsed = double.tryParse(raw);
    if (parsed == null) {
      _controller.text = _formatQuantity(widget.quantity);
      return;
    }
    if (parsed <= 0) {
      widget.onCommit(widget.productId, 0);
      return;
    }
    if ((parsed - widget.quantity).abs() < 0.0001) {
      _controller.text = _formatQuantity(widget.quantity);
      return;
    }
    widget.onCommit(widget.productId, parsed);
  }

  @override
  void didUpdateWidget(covariant _CartLineQuantityField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      _controller.text = _formatQuantity(widget.quantity);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Quantité',
      textField: true,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        autocorrect: false,
        enableSuggestions: false,
        style: widget.style,
        onSubmitted: (_) => _focus.unfocus(),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        ),
      ),
    );
  }
}

/// Contenu centré affiché lorsque le panier ne contient aucune ligne.
class _CartDrawerEmptyState extends StatelessWidget {
  const _CartDrawerEmptyState({
    required this.onVar,
    required this.textTheme,
  });

  final Color onVar;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(StocklyLayout.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(StocklyLayout.radiusLg),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: HIcon(
                AppHugeIcons.shoppingCart,
                size: 40,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: StocklyLayout.spaceLg),
            Text(
              'Panier vide',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sélectionnez des produits dans la liste\npour commencer la vente.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: onVar,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton compact − / + sur une ligne panier (style primaire pour le +).
/// [embedded] : bordure allégée pour l’intérieur de la barre « Quantité ».
class _QtyChip extends StatelessWidget {
  const _QtyChip({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.embedded = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isPlus = isPrimary;
    final fill = embedded
        ? (isPlus
            ? colorScheme.primary.withValues(alpha: 0.16)
            : colorScheme.surface.withValues(alpha: 0.01))
        : (isPlus
            ? colorScheme.primary.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest);
    final border = embedded
        ? (isPlus
            ? colorScheme.primary.withValues(alpha: 0.28)
            : colorScheme.outline.withValues(alpha: 0.12))
        : (isPlus
            ? colorScheme.primary.withValues(alpha: 0.3)
            : colorScheme.outline.withValues(alpha: 0.2));
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(StocklyLayout.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StocklyLayout.radiusSm),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: embedded ? 10 : 12,
            vertical: embedded ? 6 : 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StocklyLayout.radiusSm),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: embedded ? 17 : 18,
              fontWeight: FontWeight.w700,
              color: isPlus ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Ligne produit pour la liste POS : badge stock, prix, libellé, type / quantité.
class _PosProductListRow extends StatelessWidget {
  const _PosProductListRow({
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVar = colorScheme.onSurfaceVariant;
    final isDark = context.theme.brightness == Brightness.dark;
    final low = product.quantity <= product.safetyStock;
    final stockColor = low ? Colors.orange : Colors.green;
    final stockBadgeTextColor = isDark
        ? (low ? const Color(0xFFFDBA74) : const Color(0xFF86EFAC))
        : stockColor.shade700;

    return ProductListRow(
      product: product,
      onTap: onTap,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: stockColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  low ? 'STOCK BAS' : 'EN STOCK',
                  style: TextStyle(
                    color: stockBadgeTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              CurrencyText(
                product.sellingPrice,
                amountStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: onSurface,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            spacing: 4,
            children: [
              HIcon(
                product.type == ProductType.service
                    ? AppHugeIcons.wrench
                    : AppHugeIcons.box,
                size: 16,
                color: onSurfaceVar.withValues(alpha: 0.6),
              ),
              Text(
                'Qté · ${product.quantity.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: onSurfaceVar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sélection d’un [PaymentMethod] dans le bottom sheet de paiement.
class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      showCheckmark: false,
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: context.colorScheme.primary,
      labelStyle: TextStyle(
        color: selected
            ? context.colorScheme.onPrimary
            : context.colorScheme.onSurface,
      ),
    );
  }
}
