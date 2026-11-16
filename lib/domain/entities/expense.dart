import 'id_factory.dart';

class Expense {
  final String id;
  final String description;
  final double amount;
  final String category;
  final String userId;
  final DateTime date;

  Expense({
    String? id,
    required this.description,
    required this.amount,
    required this.category,
    required this.userId,
    DateTime? date,
  })  : id = id ?? newEntityId(),
        date = date ?? DateTime.now();
}
