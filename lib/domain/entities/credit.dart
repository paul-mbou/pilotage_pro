import 'id_factory.dart';

class Credit {
  final String id;
  final String customerName;
  final String? customerPhone;
  final double amount;
  final double amountPaid;
  final String? invoiceId;
  final DateTime date;
  final DateTime? dueDate;
  final bool isCustomerCredit;

  Credit({
    String? id,
    required this.customerName,
    this.customerPhone,
    required this.amount,
    this.amountPaid = 0,
    this.invoiceId,
    DateTime? date,
    this.dueDate,
    this.isCustomerCredit = true,
  })  : id = id ?? newEntityId(),
        date = date ?? DateTime.now();

  double get remaining => amount - amountPaid;
  bool get isOverdue =>
      dueDate != null && DateTime.now().isAfter(dueDate!) && remaining > 0;
}
