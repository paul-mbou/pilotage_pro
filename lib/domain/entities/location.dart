import 'id_factory.dart';

class Location {
  final String id;
  final String name;
  final String? address;
  final bool isActive;

  Location({
    String? id,
    required this.name,
    this.address,
    this.isActive = true,
  }) : id = id ?? newEntityId();
}
