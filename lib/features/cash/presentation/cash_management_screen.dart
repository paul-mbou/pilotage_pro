import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/core/widgets/currency_text.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';
import 'package:pilotage_pro/core/widgets/invoice_style_card.dart';

class CashManagementScreen extends ConsumerStatefulWidget {
  const CashManagementScreen({super.key});

  @override
  ConsumerState<CashManagementScreen> createState() =>
      _CashManagementScreenState();
}

class _CashManagementScreenState extends ConsumerState<CashManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);
    final cashRegisters = ref.watch(cashRegisterProvider);
    final currentRegister =
        ref.read(cashRegisterProvider.notifier).getCurrent(selectedLocation);
    final todaySales = ref.watch(todaySalesProvider);
    final colorScheme = context.colorScheme;
    final onSurface = colorScheme.onSurfaceVariant;
    final open = currentRegister != null;
    final statusColor = open ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion de la caisse')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InvoiceStyleCard(
              color: open ? Colors.green.shade50 : Colors.orange.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          open ? 'OUVERTE' : 'FERMÉE',
                          style: TextStyle(
                            color: open
                                ? Colors.green.shade700
                                : Colors.orange.shade800,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      HIcon(
                        open ? AppHugeIcons.success : AppHugeIcons.warning,
                        color: statusColor,
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    open ? 'Caisse ouverte' : 'Caisse fermée',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (open) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Ouverte le ${DateFormat('dd/MM/yyyy à HH:mm').format(currentRegister.openedAt)}',
                      style: TextStyle(color: onSurface, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CashInfo(
                          label: 'Fond de caisse',
                          value: CurrencyText(
                            currentRegister.openingAmount,
                            amountStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _CashInfo(
                          label: 'Ventes',
                          value: CurrencyText(
                            currentRegister.totalSales,
                            amountStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _CashInfo(
                          label: 'Solde théorique',
                          value: CurrencyText(
                            currentRegister.expectedAmount,
                            amountStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: open
                  ? FilledButton.icon(
                      onPressed: () => _showCloseRegisterDialog(
                        context,
                        currentRegister,
                      ),
                      icon: HIcon(
                        AppHugeIcons.lock,
                        size: 20,
                        color: colorScheme.onError,
                      ),
                      label: const Text('FERMER LA CAISSE'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: () => _showOpenRegisterDialog(
                        context,
                        selectedLocation,
                        currentUser,
                      ),
                      icon: HIcon(
                        AppHugeIcons.lockOpen,
                        size: 20,
                        color: colorScheme.onPrimary,
                      ),
                      label: const Text('OUVRIR LA CAISSE'),
                    ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Text(
                'Résumé de la journée',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            InvoiceStyleCard(
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
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "AUJOURD'HUI",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _CashRow(
                    label: 'Ventes du jour',
                    value: CurrencyText(
                      todaySales,
                      amountStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    color: Colors.green,
                  ),
                  const Divider(height: 24),
                  _CashRow(
                    label: 'Dépenses',
                    value: CurrencyText(
                      ref.watch(expenseProvider.notifier).totalMonth,
                      amountStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    color: Colors.red,
                  ),
                  const Divider(height: 24),
                  _CashRow(
                    label: 'Crédits accordés',
                    value: CurrencyText(
                      ref.watch(creditProvider.notifier).totalCustomerCredits,
                      amountStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    color: Colors.orange,
                  ),
                  const Divider(height: 24),
                  const _CashRow(
                    label: 'Recettes',
                    value: CurrencyText(
                      0,
                      amountStyle: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Text(
                'Historique des caisses',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            ...cashRegisters.map(
              (cr) {
                final closed = cr.closedAt != null;
                return InvoiceStyleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: closed
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              closed ? 'FERMÉE' : 'OUVERTE',
                              style: TextStyle(
                                color: closed
                                    ? Colors.green.shade700
                                    : Colors.orange.shade800,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (closed && cr.difference != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (cr.difference! > 0)
                                  const Text(
                                    '+',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                CurrencyText(
                                  cr.difference!,
                                  amountStyle: TextStyle(
                                    color: cr.difference! >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              'En cours',
                              style: TextStyle(
                                color: onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
                                'Caisse ${DateFormat('dd/MM/yyyy').format(cr.openedAt)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              CurrencyText(
                                cr.openingAmount,
                                prefix: 'Fond: ',
                                amountStyle: TextStyle(
                                  color: onSurface,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          if (cr.closedAt != null)
                            Text(
                              DateFormat('dd/MM HH:mm').format(cr.closedAt!),
                              style: TextStyle(
                                color: onSurface.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showOpenRegisterDialog(
      BuildContext context, String locationId, User? user) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ouverture de caisse'),
        content: TextField(
          controller: amountController,
          decoration: const InputDecoration(
              labelText: 'Fond de caisse (XAF)', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              ref.read(cashRegisterProvider.notifier).open(CashRegister(
                    locationId: locationId,
                    openingAmount: amount,
                    cashierId: user?.id ?? 'unknown',
                  ));
              Navigator.pop(context);
            },
            child: const Text('Ouvrir'),
          ),
        ],
      ),
    );
  }

  void _showCloseRegisterDialog(BuildContext context, CashRegister register) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fermeture de caisse'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Solde théorique: '),
                CurrencyText(register.expectedAmount),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                  labelText: 'Montant réel (XAF)',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              ref
                  .read(cashRegisterProvider.notifier)
                  .close(register.id, amount);
              Navigator.pop(context);
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _CashInfo extends StatelessWidget {
  const _CashInfo({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final onSurface = context.colorScheme.onSurfaceVariant;
    return Column(
      children: [
        value,
        Text(label, style: TextStyle(color: onSurface, fontSize: 11)),
      ],
    );
  }
}

class _CashRow extends StatelessWidget {
  const _CashRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final Widget value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          value,
        ],
      ),
    );
  }
}
