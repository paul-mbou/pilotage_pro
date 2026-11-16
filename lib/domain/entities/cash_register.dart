import 'id_factory.dart';

class CashRegister {
  final String id;
  final String locationId;
  final double openingAmount;
  final double? closingAmount;
  final String cashierId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double totalSales;
  final double totalExpenses;
  final double totalCredits;
  final double totalReceipts;

  CashRegister({
    String? id,
    required this.locationId,
    required this.openingAmount,
    this.closingAmount,
    required this.cashierId,
    DateTime? openedAt,
    this.closedAt,
    this.totalSales = 0,
    this.totalExpenses = 0,
    this.totalCredits = 0,
    this.totalReceipts = 0,
  })  : id = id ?? newEntityId(),
        openedAt = openedAt ?? DateTime.now();

  double get expectedAmount =>
      openingAmount + totalSales - totalExpenses + totalReceipts - totalCredits;
  double? get difference =>
      closingAmount != null ? closingAmount! - expectedAmount : null;
}
