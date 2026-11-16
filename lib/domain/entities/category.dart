import 'id_factory.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  Category({
    String? id,
    required this.name,
    this.description,
    DateTime? createdAt,
  })  : id = id ?? newEntityId(),
        createdAt = createdAt ?? DateTime.now();

  Category copyWith({String? name, String? description}) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }
}
