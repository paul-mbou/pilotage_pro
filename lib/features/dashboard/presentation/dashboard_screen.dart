import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme/design_tokens.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/core/widgets/currency_text.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';
import 'package:pilotage_pro/core/widgets/invoice_style_card.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productProvider);
    final invoices = ref.watch(invoiceProvider);
    final lowStock = ref.watch(lowStockProductsProvider);
    final todaySales = ref.watch(todaySalesProvider);
    final monthSales = ref.watch(monthSalesProvider);
    final credits = ref.watch(creditProvider);
    final currentUser = ref.watch(currentUserProvider);
    final locations = ref.watch(locationProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);
    final selectedLocationName = locations
            .where((l) => l.id == selectedLocation)
            .cast<Location?>()
            .firstWhere(
              (l) => l != null,
              orElse: () => null,
            )
            ?.name ??
        'Point de vente';

    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          PopupMenuButton<String>(
            icon: HIcon(
              AppHugeIcons.location,
              size: 22,
              color: colorScheme.onSurface,
            ),
            tooltip: 'Point de vente',
            onSelected: (locId) =>
                ref.read(selectedLocationProvider.notifier).select(locId),
            itemBuilder: (context) => locations
                .map(
                  (loc) => PopupMenuItem<String>(
                    value: loc.id,
                    padding: EdgeInsets.zero,
                    height: 48,
                    child: _LocationMenuEntry(
                      name: loc.name,
                      selected: loc.id == selectedLocation,
                    ),
                  ),
                )
                .toList(),
          ),
          IconButton(
            icon: HIcon(
              AppHugeIcons.settings,
              size: 22,
              color: colorScheme.onSurface,
            ),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
              InvoiceStyleCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        currentUser?.name.substring(0, 1) ?? 'U',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bonjour, ${currentUser?.name ?? 'Utilisateur'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentUser?.roleDisplay ?? '',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedLocationName,
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Stats Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2 / 1.3,
                  children: [
                    _StatCard(
                      title: 'Ventes du jour',
                      value: CurrencyText(
                        todaySales,
                        textAlign: TextAlign.end,
                        amountStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      icon: AppHugeIcons.chartLine,
                      color: Colors.green,
                      onTap: () => context.push('/invoices'),
                    ),
                    _StatCard(
                      title: 'Ventes du mois',
                      value: CurrencyText(
                        monthSales,
                        textAlign: TextAlign.end,
                        amountStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      icon: AppHugeIcons.calendar,
                      color: colorScheme.primary,
                      onTap: () => context.push('/reports'),
                    ),
                    _StatCard(
                      title: 'Stock total',
                      value: Text(
                        '${products.length} articles',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      icon: AppHugeIcons.box,
                      color: Colors.orange,
                      onTap: () => context.push('/products'),
                    ),
                    _StatCard(
                      title: 'Crédits clients',
                      value: CurrencyText(
                        credits
                            .where((c) => c.isCustomerCredit)
                            .fold(0.0, (sum, c) => sum + c.remaining),
                        textAlign: TextAlign.end,
                        amountStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      icon: AppHugeIcons.wallet,
                      color: Colors.red,
                      onTap: () => context.push('/reports'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Revenue Chart
              ref.watch(monthlyRevenueProvider).when(
                    data: (monthlyRevenue) {
                      final maxSales = monthlyRevenue.isEmpty
                          ? 0.0
                          : monthlyRevenue
                              .map((m) => m.sales)
                              .reduce((a, b) => a > b ? a : b);
                      return InvoiceStyleCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Évolution du chiffre d'affaires",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.push('/reports'),
                                  child: const Text('Voir plus'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: (maxSales == 0 ? 1.0 : maxSales) * 1.2,
                                  barTouchData: BarTouchData(enabled: true),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= 0 &&
                                              value.toInt() <
                                                  monthlyRevenue.length) {
                                            return Text(
                                              monthlyRevenue[value.toInt()]
                                                  .month,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 60,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            '${(value / 1000000).toStringAsFixed(1)}M',
                                            style:
                                                const TextStyle(fontSize: 10),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: Colors.grey.shade200,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  barGroups: monthlyRevenue
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    return BarChartGroupData(
                                      x: entry.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: entry.value.sales,
                                          color: colorScheme.primary,
                                          width: 20,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(4),
                                          ),
                                        ),
                                        BarChartRodData(
                                          toY: entry.value.expenses,
                                          color: Colors.red.shade300,
                                          width: 20,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(4),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _LegendItem(
                                  color: colorScheme.primary,
                                  label: 'Ventes',
                                ),
                                const SizedBox(width: 16),
                                _LegendItem(
                                  color: Colors.red.shade300,
                                  label: 'Dépenses',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const InvoiceStyleCard(
                      child: SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (e, _) => InvoiceStyleCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text("Impossible d'afficher le graphique : $e"),
                      ),
                    ),
                  ),
              const SizedBox(height: 8),

              // Low Stock Alert
              if (lowStock.isNotEmpty) ...[
                InvoiceStyleCard(
                  color: Colors.red.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'STOCK BAS',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...lowStock.take(3).map(
                            (product) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${product.quantity.toStringAsFixed(0)} / ${product.safetyStock.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      if (lowStock.length > 3)
                        TextButton(
                          onPressed: () => context.push('/products'),
                          child: Text(
                            '+ ${lowStock.length - 3} autres',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Recent Invoices
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dernières ventes',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () => context.push('/invoices'),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...invoices.take(5).map(
                    (invoice) => InvoiceStyleCard(
                      onTap: () => context.push('/invoices/${invoice.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(invoice.status)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getStatusLabel(invoice.status),
                                      style: TextStyle(
                                        color: _getStatusColor(invoice.status),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              CurrencyText(
                                invoice.total,
                                amountStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    invoice.invoiceNumber,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    invoice.customerName ?? 'Client anonyme',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    invoice.cashierName,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(invoice.createdAt),
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 24),

              // Quick Actions
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Accès rapide',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2 / 1.2,
                  ),
                  children: [
                    _QuickActionButton(
                      icon: AppHugeIcons.pos,
                      label: 'Nouvelle vente',
                      color: Colors.green,
                      onTap: () => context.push('/pos'),
                    ),
                    _QuickActionButton(
                      icon: AppHugeIcons.addBox,
                      label: 'Mise en stock',
                      color: Colors.blue,
                      onTap: () => context.push('/stock/entry'),
                    ),
                    _QuickActionButton(
                      icon: AppHugeIcons.people,
                      label: 'Utilisateurs',
                      color: Colors.purple,
                      onTap: () => context.push('/users'),
                    ),
                    _QuickActionButton(
                      icon: AppHugeIcons.bank,
                      label: 'Gestion caisse',
                      color: Colors.orange,
                      onTap: () => context.push('/cash'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.payee:
        return Colors.green;
      case InvoiceStatus.enAttente:
        return Colors.orange;
      case InvoiceStatus.annulee:
        return Colors.red;
    }
  }

  String _getStatusLabel(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.payee:
        return 'PAYÉE';
      case InvoiceStatus.enAttente:
        return 'EN ATTENTE';
      case InvoiceStatus.annulee:
        return 'ANNULÉE';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final Widget value;
  final List<List<dynamic>> icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = context.colorScheme.onSurfaceVariant;
    return InvoiceStyleCard(
      margin: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: value),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              HIcon(icon, size: 16, color: onSurface),
              const SizedBox(width: 6),
              Text(
                'Ouvrir',
                style: TextStyle(fontSize: 12, color: onSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: InvoiceStyleCard(
        margin: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ACTION',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                HIcon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Ouvrir',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne de menu « point de vente » : fond sélection, Hugeicons, typo du thème.
class _LocationMenuEntry extends StatelessWidget {
  const _LocationMenuEntry({
    required this.name,
    required this.selected,
  });

  final String name;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.5)
              : null,
          borderRadius: BorderRadius.circular(StocklyLayout.radiusMd),
        ),
        child: Row(
          children: [
            HIcon(
              selected ? AppHugeIcons.check : AppHugeIcons.circleOutline,
              size: 20,
              color:
                  selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
