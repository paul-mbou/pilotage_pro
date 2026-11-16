import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/core/theme/design_tokens.dart';
import 'package:pilotage_pro/core/widgets/currency_text.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';

Future<void> _runCancelInvoice(
  BuildContext context,
  WidgetRef ref,
  Invoice invoice,
) async {
  final isPaid = invoice.status == InvoiceStatus.payee;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        isPaid
            ? 'Annuler une facture payée ?'
            : 'Annuler une facture en attente ?',
      ),
      content: Text(
        isPaid
            ? 'Cette facture est enregistrée comme payée. L’annulation la '
                'passera en « facture annulée » et pourra impacter le suivi des '
                'ventes. Voulez-vous continuer ?'
            : 'Cette facture est en attente de paiement. L’annulation la '
                'passera en « facture annulée » et pourra impacter le suivi. '
                'Voulez-vous continuer ?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Retour'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Confirmer l’annulation',
              style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  ref
      .read(invoiceProvider.notifier)
      .updateInvoice(invoice.copyWith(status: InvoiceStatus.annulee));
  if (context.mounted) context.pop();
}

Future<void> _runMarkInvoicePaid(
  BuildContext context,
  WidgetRef ref,
  Invoice invoice,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Marquer comme payée ?'),
      content: const Text(
        'La facture passera en statut « payée » et la date de paiement '
        'sera enregistrée. Voulez-vous continuer ?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Retour'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Confirmer', style: TextStyle(color: Colors.green)),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  ref.read(invoiceProvider.notifier).updateInvoice(
        invoice.copyWith(
          status: InvoiceStatus.payee,
          paidAt: DateTime.now(),
        ),
      );
  if (context.mounted) context.pop();
}

class InvoiceDetailScreen extends ConsumerWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoice =
        ref.watch(invoiceProvider).firstWhere((i) => i.id == invoiceId);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        actions: [
          IconButton(
            icon: HIcon(
              AppHugeIcons.print,
              size: 22,
              color: context.colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: HIcon(
              AppHugeIcons.share,
              size: 22,
              color: context.colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(invoice.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(invoice.status).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      HIcon(
                        _getStatusIcon(invoice.status),
                        color: _getStatusColor(invoice.status),
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusLabel(invoice.status),
                        style: TextStyle(
                            color: _getStatusColor(invoice.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  if (invoice.isCredit)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'CRÉDIT',
                        style: TextStyle(
                          color: context.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Grid
            Row(
              children: [
                Expanded(
                    child: _InfoBox(
                        label: 'Date',
                        value: dateFormat.format(invoice.createdAt),
                        icon: AppHugeIcons.calendar)),
                const SizedBox(width: 12),
                Expanded(
                    child: _InfoBox(
                        label: 'Caissier',
                        value: invoice.cashierName,
                        icon: AppHugeIcons.user)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _InfoBox(
                        label: 'Mode de paiement',
                        value: _getPaymentLabel(invoice.paymentMethod),
                        icon: AppHugeIcons.pos)),
                const SizedBox(width: 12),
                Expanded(
                    child: _InfoBox(
                        label: 'Point de vente',
                        value: ref
                            .watch(locationProvider)
                            .firstWhere((l) => l.id == invoice.locationId,
                                orElse: () => Location(name: 'Inconnu'))
                            .name,
                        icon: AppHugeIcons.location)),
              ],
            ),
            if (invoice.customerName != null) ...[
              const SizedBox(height: 12),
              _InfoBox(
                  label: 'Client',
                  value:
                      '${invoice.customerName}${invoice.customerPhone != null ? ' • ${invoice.customerPhone}' : ''}',
                  icon: AppHugeIcons.userOutline,
                  fullWidth: true),
            ],
            const SizedBox(height: 24),

            // Items
            Text(
              'Articles',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ...invoice.items.map((item) {
                    final onVar = context.colorScheme.onSurfaceVariant;
                    return ListTile(
                      title: Text(
                        item.productName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            '${item.quantity.toStringAsFixed(0)} × ',
                            style: TextStyle(
                              color: onVar,
                              fontSize: 13,
                            ),
                          ),
                          CurrencyText(
                            item.unitPrice,
                            amountStyle: TextStyle(
                              color: onVar,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      trailing: CurrencyText(
                        item.total,
                        amountStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    );
                  }),
                  const Divider(),
                  _TotalRow(
                      label: 'Sous-total',
                      value: CurrencyText(
                        invoice.subtotal,
                        amountStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      )),
                  if (invoice.discount > 0)
                    _TotalRow(
                        label: 'Remise',
                        value: CurrencyText(
                          -invoice.discount,
                          amountStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        )),
                  if (invoice.tax > 0)
                    _TotalRow(
                        label: 'Taxes',
                        value: CurrencyText(
                          invoice.tax,
                          amountStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        )),
                  const Divider(),
                  _TotalRow(
                    label: 'TOTAL',
                    value: CurrencyText(
                      invoice.total,
                      amountStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    isBold: true,
                  ),
                  if (invoice.isCredit) ...[
                    const Divider(),
                    _TotalRow(
                        label: 'Montant payé',
                        value: CurrencyText(
                          invoice.amountPaid ?? 0,
                          amountStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        )),
                    _TotalRow(
                        label: 'Reste à payer',
                        value: CurrencyText(
                          invoice.remainingAmount,
                          amountStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        )),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            if (invoice.status != InvoiceStatus.annulee) ...[
              Row(
                children: [
                  if (invoice.status == InvoiceStatus.enAttente)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _runMarkInvoicePaid(
                          context,
                          ref,
                          invoice,
                        ),
                        icon: const HIcon(
                          AppHugeIcons.check,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Text('MARQUER PAYÉE'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          minimumSize: const Size(64, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              StocklyLayout.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (invoice.status == InvoiceStatus.enAttente)
                    const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _runCancelInvoice(
                        context,
                        ref,
                        invoice,
                      ),
                      icon: const HIcon(
                        AppHugeIcons.cancel,
                        size: 20,
                        color: Colors.red,
                      ),
                      label: const Text('ANNULER'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        minimumSize: const Size(64, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            StocklyLayout.radiusMd,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
          ],
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

  List<List<dynamic>> _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.payee:
        return AppHugeIcons.success;
      case InvoiceStatus.enAttente:
        return AppHugeIcons.pending;
      case InvoiceStatus.annulee:
        return AppHugeIcons.cancel;
    }
  }

  String _getStatusLabel(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.payee:
        return 'Facture payée';
      case InvoiceStatus.enAttente:
        return 'En attente de paiement';
      case InvoiceStatus.annulee:
        return 'Facture annulée';
    }
  }

  String _getPaymentLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.espece:
        return 'Espèces';
      case PaymentMethod.carte:
        return 'Carte bancaire';
      case PaymentMethod.mobile:
        return 'Mobile Money';
      case PaymentMethod.credit:
        return 'Crédit';
    }
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final List<List<dynamic>> icon;
  final bool fullWidth;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final onSurface = colorScheme.onSurface;
    final onVar = colorScheme.onSurfaceVariant;
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HIcon(icon, size: 16, color: onVar),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: onVar,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final Widget value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final onSurface = context.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: onSurface,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          DefaultTextStyle.merge(
            style: TextStyle(color: onSurface),
            child: value,
          ),
        ],
      ),
    );
  }
}
