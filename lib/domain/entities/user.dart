import 'business_enums.dart';
import 'id_factory.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? locationId;
  final bool isActive;
  final DateTime createdAt;

  User({
    String? id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.locationId,
    this.isActive = true,
    DateTime? createdAt,
  })  : id = id ?? newEntityId(),
        createdAt = createdAt ?? DateTime.now();

  String get roleDisplay {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.vendeur:
        return 'Vendeur';
      case UserRole.caissier:
        return 'Caissier';
    }
  }
}
