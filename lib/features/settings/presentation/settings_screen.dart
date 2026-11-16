import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final locations = ref.watch(locationProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);

    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          // User Profile
          Container(
            padding: const EdgeInsets.all(24),
            color: colorScheme.primaryContainer.withValues(alpha: 0.45),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    currentUser?.name.substring(0, 1) ?? 'U',
                    style: TextStyle(
                      fontSize: 32,
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(currentUser?.name ?? 'Utilisateur',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(currentUser?.email ?? '',
                    style: TextStyle(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentUser?.roleDisplay ?? '',
                    style:
                        TextStyle(color: colorScheme.onPrimary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Location Settings
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'POINT DE VENTE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...locations.map((loc) => RadioListTile<String>(
                title: Text(loc.name),
                subtitle: Text(loc.address ?? ''),
                value: loc.id,
                groupValue: selectedLocation,
                onChanged: (v) =>
                    ref.read(selectedLocationProvider.notifier).select(v!),
              )),

          // App Settings
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'APPLICATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ListTile(
            leading: HIcon(AppHugeIcons.language, color: colorScheme.onSurface),
            title: const Text('Langue'),
            subtitle: const Text('Français'),
            trailing: HIcon(
              AppHugeIcons.chevron,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: HIcon(AppHugeIcons.currency, color: colorScheme.onSurface),
            title: const Text('Devise'),
            subtitle: const Text('XAF (Franc CFA)'),
            trailing: HIcon(
              AppHugeIcons.chevron,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: HIcon(AppHugeIcons.palette, color: colorScheme.onSurface),
            title: const Text('Thème d\'affichage'),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<ThemeMode>(
                value: ref.watch(themeModeProvider),
                borderRadius: BorderRadius.circular(12),
                onChanged: (v) {
                  if (v != null) {
                    ref.read(themeModeProvider.notifier).setMode(v);
                  }
                },
                items: const [
                  DropdownMenuItem(
                      value: ThemeMode.system, child: Text('Système')),
                  DropdownMenuItem(
                      value: ThemeMode.light, child: Text('Clair')),
                  DropdownMenuItem(
                      value: ThemeMode.dark, child: Text('Sombre')),
                ],
              ),
            ),
          ),
          ListTile(
            leading:
                HIcon(AppHugeIcons.notification, color: colorScheme.onSurface),
            title: const Text('Notifications'),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),

          // Data Management
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'DONNÉES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ListTile(
            leading:
                HIcon(AppHugeIcons.cloudUpload, color: colorScheme.onSurface),
            title: const Text('Sauvegarde'),
            subtitle: const Text('Dernière: 22/04/2026'),
            trailing: HIcon(
              AppHugeIcons.chevron,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: HIcon(AppHugeIcons.databaseImport,
                color: colorScheme.onSurface),
            title: const Text('Restaurer'),
            trailing: HIcon(
              AppHugeIcons.chevron,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const HIcon(AppHugeIcons.delete, color: Colors.red),
            title: const Text('Réinitialiser les données',
                style: TextStyle(color: Colors.red)),
            onTap: () => _showResetDialog(context),
          ),

          // About
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'À PROPOS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ListTile(
            leading: HIcon(AppHugeIcons.info, color: colorScheme.onSurface),
            title: const Text('Pilotage Pro'),
            subtitle: const Text('Version 1.0.0'),
          ),
          ListTile(
            leading: HIcon(AppHugeIcons.support, color: colorScheme.onSurface),
            title: const Text('Support technique'),
            subtitle: const Text('support@pilotage.pro'),
          ),

          // Logout
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/');
                },
                icon: const HIcon(
                  AppHugeIcons.logout,
                  size: 20,
                  color: Colors.red,
                ),
                label: const Text('DÉCONNEXION'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser ?'),
        content: const Text(
            'Toutes les données seront perdues. Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Réinitialiser',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
