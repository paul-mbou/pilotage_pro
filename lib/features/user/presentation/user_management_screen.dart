import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/theme_context.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userProvider);
    final locations = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        actions: [
          IconButton(
            icon: HIcon(
              AppHugeIcons.add,
              size: 22,
              color: context.colorScheme.onSurface,
            ),
            onPressed: () => _showUserForm(context, ref),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final location = locations.firstWhere((l) => l.id == user.locationId,
              orElse: () => Location(name: 'Non assigné'));
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: user.isActive
                    ? context.colorScheme.primaryContainer
                    : context.colorScheme.surfaceContainerHighest,
                child: Text(
                  user.name.substring(0, 1),
                  style: TextStyle(
                    color: user.isActive
                        ? context.colorScheme.onPrimaryContainer
                        : context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              title: Text(user.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  Text('${user.roleDisplay} • ${location.name}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              trailing: Switch(
                value: user.isActive,
                onChanged: (_) =>
                    ref.read(userProvider.notifier).toggleActive(user.id),
              ),
              onTap: () => _showUserForm(context, ref, user: user),
            ),
          );
        },
      ),
    );
  }

  void _showUserForm(BuildContext context, WidgetRef ref, {User? user}) {
    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);
    final phoneController = TextEditingController(text: user?.phone);

    UserRole role = user?.role ?? UserRole.vendeur;
    String locationId = user?.locationId ?? ref.read(locationProvider).first.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    user == null
                        ? 'Nouvel utilisateur'
                        : 'Modifier utilisateur',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'Nom complet',
                        border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                        labelText: 'Téléphone', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  decoration: const InputDecoration(
                      labelText: 'Rôle', border: OutlineInputBorder()),
                  initialValue: role,
                  items: UserRole.values
                      .map((r) => DropdownMenuItem(
                          value: r, child: Text(r.toString().split('.').last)))
                      .toList(),
                  onChanged: (v) => setState(() => role = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'Point de vente',
                      border: OutlineInputBorder()),
                  initialValue: locationId,
                  items: ref
                      .read(locationProvider)
                      .map((l) =>
                          DropdownMenuItem(value: l.id, child: Text(l.name)))
                      .toList(),
                  onChanged: (v) => setState(() => locationId = v!),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final newUser = User(
                        id: user?.id,
                        name: nameController.text,
                        email: emailController.text,
                        phone: phoneController.text.isEmpty
                            ? null
                            : phoneController.text,
                        role: role,
                        locationId: locationId,
                        isActive: user?.isActive ?? true,
                      );
                      if (user == null) {
                        ref.read(userProvider.notifier).add(newUser);
                      } else {
                        ref.read(userProvider.notifier).update(newUser);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(user == null ? 'CRÉER' : 'METTRE À JOUR'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
