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
import 'package:pilotage_pro/core/widgets/invoice_style_card.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  String _searchQuery = '';
  InvoiceStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final invoices = ref.watch(invoiceProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    var filteredInvoices = invoices.where((i) {
      final matchesSearch = _searchQuery.isEmpty ||
          i.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ==
              true ||
          i.cashierName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == null || i.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des factures'),
        actions: [
          PopupMenuButton<InvoiceStatus?>(
            icon: HIcon(
              AppHugeIcons.filter,
              size: 22,
              color: context.colorScheme.onSurface,
            ),
            onSelected: (v) => setState(() => _statusFilter = v),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Tous')),
              const PopupMenuItem(
                  value: InvoiceStatus.payee,
                  child: Row(children: [
                    HIcon(
                      AppHugeIcons.success,
                      color: Colors.green,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Payée')
                  ])),
              const PopupMenuItem(
                  value: InvoiceStatus.enAttente,
                  child: Row(children: [
                    HIcon(
                      AppHugeIcons.pending,
                      color: Colors.orange,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('En attente')
                  ])),
              const PopupMenuItem(
                  value: InvoiceStatus.annulee,
                  child: Row(children: [
                    HIcon(
                      AppHugeIcons.cancel,
                      color: Colors.red,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Annulée')
                  ])),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une facture...',
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: filteredInvoices.isEmpty
                ? const Center(child: Text('Aucune facture trouvée'))
                : ListView.builder(
                    itemCount: filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = filteredInvoices[index];
                      return InvoiceStyleCard(
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
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(invoice.status)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _getStatusLabel(invoice.status),
                                        style: TextStyle(
                                            color:
                                                _getStatusColor(invoice.status),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    if (invoice.isCredit) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Text('CRÉDIT',
                                            style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
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
                                    Text(invoice.invoiceNumber,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        invoice.customerName ??
                                            'Client anonyme',
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(invoice.cashierName,
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12)),
                                    Text(dateFormat.format(invoice.createdAt),
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                            if (invoice.isCredit &&
                                invoice.remainingAmount > 0) ...[
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value:
                                    (invoice.amountPaid ?? 0) / invoice.total,
                                backgroundColor: Colors.red.shade100,
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.green),
                              ),
                              const SizedBox(height: 4),
                              CurrencyText(
                                invoice.remainingAmount,
                                prefix: 'Reste: ',
                                amountStyle: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
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
}
