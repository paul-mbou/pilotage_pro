import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/core/widgets/currency_text.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';

class FinancialReportScreen extends ConsumerWidget {
  const FinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoiceProvider);
    final credits = ref.watch(creditProvider);
    final expenses = ref.watch(expenseProvider);
    final totalSales = invoices
        .where((i) => i.status == InvoiceStatus.payee)
        .fold(0.0, (sum, i) => sum + i.total);
    final totalPending = invoices
        .where((i) => i.status == InvoiceStatus.enAttente)
        .fold(0.0, (sum, i) => sum + i.total);
    final totalCustomerCredits = credits
        .where((c) => c.isCustomerCredit)
        .fold(0.0, (sum, c) => sum + c.remaining);
    final totalSupplierDebts = credits
        .where((c) => !c.isCustomerCredit)
        .fold(0.0, (sum, c) => sum + c.remaining);
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rapports financiers'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: HIcon(AppHugeIcons.chartLine, size: 20),
                text: "Chiffre d'affaires",
              ),
              Tab(
                icon: HIcon(AppHugeIcons.wallet, size: 20),
                text: 'Crédits & Dettes',
              ),
              Tab(
                icon: HIcon(AppHugeIcons.percent, size: 20),
                text: 'Marges',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Revenue Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _ReportCard(
                              title: 'Ventes totales',
                              value: CurrencyText(
                                totalSales,
                                amountStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              color: Colors.green,
                              icon: AppHugeIcons.chartLine)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _ReportCard(
                              title: 'En attente',
                              value: CurrencyText(
                                totalPending,
                                amountStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              color: Colors.orange,
                              icon: AppHugeIcons.pending)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _ReportCard(
                              title: 'Dépenses',
                              value: CurrencyText(
                                totalExpenses,
                                amountStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              color: Colors.red,
                              icon: AppHugeIcons.stockIn)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ReportCard(
                          title: 'Bénéfice net',
                          value: CurrencyText(
                            totalSales - totalExpenses,
                            amountStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.colorScheme.primary,
                            ),
                          ),
                          color: context.colorScheme.primary,
                          icon: AppHugeIcons.savings,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...ref.watch(monthlyRevenueProvider).when(
                        data: (monthlyRevenue) => [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Évolution mensuelle',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      )),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 250,
                                    child: LineChart(
                                      LineChartData(
                                        gridData: const FlGridData(
                                            show: true,
                                            drawVerticalLine: false),
                                        titlesData: FlTitlesData(
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                final i = value.toInt();
                                                if (i < 0 ||
                                                    i >=
                                                        monthlyRevenue.length) {
                                                  return const Text('');
                                                }
                                                return Text(
                                                  monthlyRevenue[i].month,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 60,
                                              getTitlesWidget: (value, meta) =>
                                                  Text(
                                                '${(value / 1000000).toStringAsFixed(1)}M',
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              ),
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: monthlyRevenue
                                                .asMap()
                                                .entries
                                                .map((e) => FlSpot(
                                                    e.key.toDouble(),
                                                    e.value.sales))
                                                .toList(),
                                            isCurved: true,
                                            color: Colors.green,
                                            barWidth: 3,
                                            dotData:
                                                const FlDotData(show: true),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color:
                                                  Colors.green.withOpacity(0.1),
                                            ),
                                          ),
                                          LineChartBarData(
                                            spots: monthlyRevenue
                                                .asMap()
                                                .entries
                                                .map((e) => FlSpot(
                                                    e.key.toDouble(),
                                                    e.value.expenses))
                                                .toList(),
                                            isCurved: true,
                                            color: Colors.red,
                                            barWidth: 3,
                                            dotData:
                                                const FlDotData(show: true),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _LegendItem(
                                        color: Colors.green,
                                        label: 'Ventes',
                                      ),
                                      SizedBox(width: 16),
                                      _LegendItem(
                                        color: Colors.red,
                                        label: 'Dépenses',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Récapitulatif mensuel',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      )),
                                  const SizedBox(height: 12),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('Mois')),
                                        DataColumn(
                                            label: Text('Ventes'),
                                            numeric: true),
                                        DataColumn(
                                            label: Text('Crédits'),
                                            numeric: true),
                                        DataColumn(
                                            label: Text('Recettes'),
                                            numeric: true),
                                        DataColumn(
                                            label: Text('Dépenses'),
                                            numeric: true),
                                        DataColumn(
                                            label: Text('Net'), numeric: true),
                                      ],
                                      rows: monthlyRevenue
                                          .map(
                                            (m) => DataRow(
                                              cells: [
                                                DataCell(
                                                  Text(
                                                    m.month,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: CurrencyText(
                                                      m.sales,
                                                      amountStyle:
                                                          const TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: CurrencyText(
                                                      m.credits,
                                                      amountStyle:
                                                          const TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: CurrencyText(
                                                      m.receipts,
                                                      amountStyle:
                                                          const TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: CurrencyText(
                                                      m.expenses,
                                                      amountStyle:
                                                          const TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: CurrencyText(
                                                      m.netRevenue,
                                                      amountStyle: TextStyle(
                                                        color: m.netRevenue >= 0
                                                            ? Colors.green
                                                            : Colors.red,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        loading: () => [
                          const Card(
                            child: SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        ],
                        error: (e, _) => [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('Données mensuelles: $e'),
                            ),
                          ),
                        ],
                      ),
                ],
              ),
            ),

            // Credits Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _ReportCard(
                              title: 'Crédits clients',
                              value: CurrencyText(
                                totalCustomerCredits,
                                amountStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              color: Colors.orange,
                              icon: AppHugeIcons.people)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _ReportCard(
                              title: 'Dettes fournisseurs',
                              value: CurrencyText(
                                totalSupplierDebts,
                                amountStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              color: Colors.red,
                              icon: AppHugeIcons.business)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Crédits clients',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...credits.where((c) => c.isCustomerCredit).map(
                        (c) => _CreditCard(credit: c),
                      ),
                  const SizedBox(height: 24),
                  const Text('Dettes fournisseurs',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...credits.where((c) => !c.isCustomerCredit).map(
                        (c) => _CreditCard(credit: c),
                      ),
                ],
              ),
            ),

            // Margins Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Marge globale',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: totalSales > 0
                                        ? ((totalSales - totalExpenses) /
                                                totalSales) *
                                            100
                                        : 0,
                                    title:
                                        '${totalSales > 0 ? (((totalSales - totalExpenses) / totalSales) * 100).toStringAsFixed(1) : 0}%',
                                    color: Colors.green,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  PieChartSectionData(
                                    value: totalSales > 0
                                        ? (totalExpenses / totalSales) * 100
                                        : 100,
                                    title:
                                        '${totalSales > 0 ? ((totalExpenses / totalSales) * 100).toStringAsFixed(1) : 0}%',
                                    color: Colors.red.shade300,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const _LegendItem(
                                  color: Colors.green,
                                  label: 'Marge bénéficiaire'),
                              const SizedBox(width: 16),
                              _LegendItem(
                                  color: Colors.red.shade300, label: 'Charges'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Marge par produit',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...ref
                      .watch(productProvider)
                      .where((p) => p.type == ProductType.produit)
                      .map((p) {
                    final margin = p.margin;
                    final marginPct = p.marginPercent;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(p.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Row(
                          children: [
                            const Text('PA: '),
                            CurrencyText(
                              p.purchasePrice,
                              amountStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(' • PV: ',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade600)),
                            CurrencyText(
                              p.sellingPrice,
                              amountStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CurrencyText(
                              margin,
                              amountStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: margin > 0 ? Colors.green : Colors.red,
                              ),
                            ),
                            Text('${marginPct.toStringAsFixed(1)}%',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final Widget value;
  final Color color;
  final List<List<dynamic>> icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HIcon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            value,
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.credit});

  final dynamic credit;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(credit.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: credit.isOverdue
                        ? Colors.red.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    credit.isOverdue ? 'EN RETARD' : 'EN COURS',
                    style: TextStyle(
                        color: credit.isOverdue ? Colors.red : Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: credit.amountPaid / credit.amount,
              backgroundColor: Colors.red.shade100,
              valueColor: const AlwaysStoppedAnimation(Colors.green),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CurrencyText(
                  credit.amountPaid,
                  prefix: 'Payé: ',
                  amountStyle: const TextStyle(fontSize: 12),
                ),
                CurrencyText(
                  credit.remaining,
                  prefix: 'Reste: ',
                  amountStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            CurrencyText(
              credit.amount,
              prefix: 'Total: ',
              amountStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
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
