import 'business_enums.dart';
import 'id_factory.dart';

class InvoiceItem {
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double discount;
  final double total;

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
  }) : total = (unitPrice * quantity) - discount;
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final List<InvoiceItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final PaymentMethod paymentMethod;
  final InvoiceStatus status;
  final String? customerName;
  final String? customerPhone;
  final String cashierId;
  final String cashierName;
  final String? locationId;
  final bool isCredit;
  final double? amountPaid;
  final DateTime createdAt;
  final DateTime? paidAt;

  Invoice({
    String? id,
    String? invoiceNumber,
    required this.items,
    this.tax = 0,
    this.discount = 0,
    required this.paymentMethod,
    this.status = InvoiceStatus.payee,
    this.customerName,
    this.customerPhone,
    required this.cashierId,
    required this.cashierName,
    this.locationId,
    this.isCredit = false,
    this.amountPaid,
    DateTime? createdAt,
    this.paidAt,
  })  : id = id ?? newEntityId(),
        invoiceNumber = invoiceNumber ??
            'FAC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        subtotal = items.fold<double>(0, (sum, item) => sum + item.total),
        total = items.fold<double>(0, (sum, item) => sum + item.total) +
            tax -
            discount,
        createdAt = createdAt ?? DateTime.now();

  double get remainingAmount => isCredit ? total - (amountPaid ?? 0) : 0;

  Invoice copyWith({
    String? invoiceNumber,
    List<InvoiceItem>? items,
    double? tax,
    double? discount,
    PaymentMethod? paymentMethod,
    InvoiceStatus? status,
    String? customerName,
    String? customerPhone,
    String? cashierId,
    String? cashierName,
    String? locationId,
    bool? isCredit,
    double? amountPaid,
    DateTime? createdAt,
    DateTime? paidAt,
  }) {
    return Invoice(
      id: id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      items: items ?? this.items,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      locationId: locationId ?? this.locationId,
      isCredit: isCredit ?? this.isCredit,
      amountPaid: amountPaid ?? this.amountPaid,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
