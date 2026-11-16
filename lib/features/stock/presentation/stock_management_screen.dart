import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';
import 'package:pilotage_pro/core/widgets/invoice_style_card.dart';

class StockManagementScreen extends ConsumerWidget {
  const StockManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final onSurface = colorScheme.onSurfaceVariant;
    final menuItems = [
      _MenuItem(
        tag: 'ENTRÉE',
        title: 'Mise en stock',
        subtitle: 'Enregistrer des entrées de marchandises',
        color: Colors.green,
        route: '/stock/entry',
      ),
      _MenuItem(
        tag: 'MOUVEMENTS',
        title: 'Mouvements',
        subtitle: 'Transferts et ajustements',
        color: Colors.blue,
        route: '/stock/movement',
      ),
      _MenuItem(
        tag: 'VALORISATION',
        title: 'Valorisation',
        subtitle: 'Valeur du stock et marges',
        color: Colors.purple,
        route: '/stock/valuation',
      ),
      _MenuItem(
        tag: 'ALERTE',
        title: 'Stock de sécurité',
        subtitle: 'Seuils et alertes',
        color: Colors.orange,
        route: '/products',
      ),
      _MenuItem(
        tag: 'BIENTÔT',
        title: 'Conversions',
        subtitle: "Changement d'unités",
        color: Colors.teal,
        route: null,
      ),
      _MenuItem(
        tag: 'BIENTÔT',
        title: 'Historique',
        subtitle: 'Tous les mouvements',
        color: colorScheme.primary,
        route: null,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion de stock')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return InvoiceStyleCard(
            onTap: item.route != null ? () => context.push(item.route!) : null,
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
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.tag,
                        style: TextStyle(
                          color: item.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.route != null)
                      HIcon(
                        AppHugeIcons.chevron,
                        color: onSurface,
                        size: 22,
                      )
                    else
                      HIcon(
                        AppHugeIcons.lock,
                        size: 18,
                        color: onSurface.withValues(alpha: 0.5),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(color: onSurface, fontSize: 13),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem {
  final String tag;
  final String title;
  final String subtitle;
  final Color color;
  final String? route;

  _MenuItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.color,
    this.route,
  });
}
