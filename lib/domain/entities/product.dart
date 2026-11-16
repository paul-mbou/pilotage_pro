import 'business_enums.dart';
import 'id_factory.dart';

class Product {
  final String id;
  final String name;
  final String? description;
  final String? barcode;
  final ProductType type;
  final String categoryId;
  final double purchasePrice;
  final double sellingPrice;
  final double? minSellingPrice;
  final double? maxSellingPrice;
  final String unit;
  final double quantity;
  final double safetyStock;
  final String? locationId;

  /// URL HTTPS d’illustration (optionnel).
  final String? imageUrl;
  final bool isComposed;
  final List<ProductComponent>? components;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    String? id,
    required this.name,
    this.description,
    this.barcode,
    this.imageUrl,
    required this.type,
    required this.categoryId,
    required this.purchasePrice,
    required this.sellingPrice,
    this.minSellingPrice,
    this.maxSellingPrice,
    this.unit = 'unité',
    this.quantity = 0,
    this.safetyStock = 0,
    this.locationId,
    this.isComposed = false,
    this.components,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? newEntityId(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get margin => sellingPrice - purchasePrice;
  double get marginPercent =>
      purchasePrice > 0 ? (margin / purchasePrice) * 100 : 0;
  double get stockValue => purchasePrice * quantity;
  double get stockValuePV => sellingPrice * quantity;
  bool get isLowStock => quantity <= safetyStock && safetyStock > 0;

  Product copyWith({
    String? name,
    String? description,
    String? barcode,
    ProductType? type,
    String? categoryId,
    double? purchasePrice,
    double? sellingPrice,
    double? minSellingPrice,
    double? maxSellingPrice,
    String? unit,
    double? quantity,
    double? safetyStock,
    String? locationId,
    String? imageUrl,
    bool? isComposed,
    List<ProductComponent>? components,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      minSellingPrice: minSellingPrice ?? this.minSellingPrice,
      maxSellingPrice: maxSellingPrice ?? this.maxSellingPrice,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      safetyStock: safetyStock ?? this.safetyStock,
      locationId: locationId ?? this.locationId,
      isComposed: isComposed ?? this.isComposed,
      components: components ?? this.components,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class ProductComponent {
  final String productId;
  final double quantity;
  final String? unit;

  ProductComponent({
    required this.productId,
    required this.quantity,
    this.unit,
  });
}
