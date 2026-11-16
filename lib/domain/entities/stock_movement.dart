import 'business_enums.dart';
import 'id_factory.dart';

class StockMovement {
  final String id;
  final String productId;
  final MovementType type;
  final double quantity;
  final double previousQuantity;
  final double newQuantity;
  final String? sourceLocationId;
  final String? destinationLocationId;
  final String? reason;
  final String userId;
  final DateTime date;
  final String? reference;

  StockMovement({
    String? id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.previousQuantity,
    required this.newQuantity,
    this.sourceLocationId,
    this.destinationLocationId,
    this.reason,
    required this.userId,
    DateTime? date,
    this.reference,
  })  : id = id ?? newEntityId(),
        date = date ?? DateTime.now();
}
