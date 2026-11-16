import 'package:pilotage_pro/data/baas/database/document_store.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';

class ProductRepository {
  ProductRepository(this._store);
  final DocumentStore _store;
  static const _collection = 'products';

  Future<List<Product>> getAll() async {
    final docs = await _store.getAll(collection: _collection);
    return docs
        .map((doc) => _productFromMap(doc.data, id: doc.id))
        .whereType<Product>()
        .toList();
  }

  Future<void> upsert(Product product) => _store.upsert(
        collection: _collection,
        id: product.id,
        data: _productToMap(product),
      );

  Future<void> delete(String id) =>
      _store.delete(collection: _collection, id: id);
}

class CategoryRepository {
  CategoryRepository(this._store);
  final DocumentStore _store;
  static const _collection = 'categories';

  Future<List<Category>> getAll() async {
    final docs = await _store.getAll(collection: _collection);
    return docs
        .map((doc) => _categoryFromMap(doc.data, id: doc.id))
        .whereType<Category>()
        .toList();
  }

  Future<void> upsert(Category category) => _store.upsert(
        collection: _collection,
        id: category.id,
        data: _categoryToMap(category),
      );

  Future<void> delete(String id) =>
      _store.delete(collection: _collection, id: id);
}

class InvoiceRepository {
  InvoiceRepository(this._store);
  final DocumentStore _store;
  static const _collection = 'invoices';

  Future<List<Invoice>> getAll() async {
    final docs = await _store.getAll(collection: _collection);
    return docs
        .map((doc) => _invoiceFromMap(doc.data, id: doc.id))
        .whereType<Invoice>()
        .toList();
  }

  Future<void> upsert(Invoice invoice) => _store.upsert(
        collection: _collection,
        id: invoice.id,
        data: _invoiceToMap(invoice),
      );

  Future<void> delete(String id) =>
      _store.delete(collection: _collection, id: id);
}

class UserRepository {
  UserRepository(this._store);
  final DocumentStore _store;
  static const _collection = 'users';

  Future<List<User>> getAll() async {
    final docs = await _store.getAll(collection: _collection);
    return docs
        .map((doc) => _userFromMap(doc.data, id: doc.id))
        .whereType<User>()
        .toList();
  }

  Future<void> upsert(User user) => _store.upsert(
      collection: _collection, id: user.id, data: _userToMap(user));

  Future<void> delete(String id) =>
      _store.delete(collection: _collection, id: id);
}

class StockMovementRepository {
  StockMovementRepository(this._store);
  final DocumentStore _store;
  static const _collection = 'stock_movements';

  Future<List<StockMovement>> getAll() async {
    final docs = await _store.getAll(collection: _collection);
    return docs
        .map((doc) => _stockMovementFromMap(doc.data, id: doc.id))
        .whereType<StockMovement>()
        .toList();
  }

  Future<void> upsert(StockMovement movement) => _store.upsert(
        collection: _collection,
        id: movement.id,
        data: _stockMovementToMap(movement),
      );
}

class LocationRepository {
  LocationRepository(this._store);
  final DocumentStore _store;
  static const _collection = 'locations';

  Future<List<Location>> getAll() async {
    final docs = await _store.getAll(collection: _collection);
    return docs
        .map((doc) => _locationFromMap(doc.data, id: doc.id))
        .whereType<Location>()
        .toList();
  }

  Future<void> upsert(Location location) => _store.upsert(
        collection: _collection,
        id: location.id,
        data: _locationToMap(location),
      );
}

class CashRegisterRepository {
  CashRegisterRepository(this._store);
  final DocumentStore _store;
  static const _collection = 'cash_registers';

  Future<List<CashRegister>> getAll() async {
    final docs = await _store.getAll(collection: _collection);
    return docs
        .map((doc) => _cashRegisterFromMap(doc.data, id: doc.id))
        .whereType<CashRegister>()
        .toList();
  }

  Future<void> upsert(CashRegister register) => _store.upsert(
        collection: _collection,
        id: register.id,
        data: _cashRegisterToMap(register),
      );
}

class CreditRepository {
  CreditRepository(this._store);
  final DocumentStore _store;
  static const _collection = 'credits';

  Future<List<Credit>> getAll() async {
    final docs = await _store.getAll(collection: _collection);
    return docs
        .map((doc) => _creditFromMap(doc.data, id: doc.id))
        .whereType<Credit>()
        .toList();
  }

  Future<void> upsert(Credit credit) => _store.upsert(
      collection: _collection, id: credit.id, data: _creditToMap(credit));
}

class ExpenseRepository {
  ExpenseRepository(this._store);
  final DocumentStore _store;
  static const _collection = 'expenses';

  Future<List<Expense>> getAll() async {
    final docs = await _store.getAll(collection: _collection);
    return docs
        .map((doc) => _expenseFromMap(doc.data, id: doc.id))
        .whereType<Expense>()
        .toList();
  }

  Future<void> upsert(Expense expense) => _store.upsert(
        collection: _collection,
        id: expense.id,
        data: _expenseToMap(expense),
      );

  Future<void> delete(String id) =>
      _store.delete(collection: _collection, id: id);
}

DateTime _readDate(Map<String, dynamic> map, String key, {DateTime? fallback}) {
  final value = map[key];
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) {
    return DateTime.tryParse(value) ?? (fallback ?? DateTime.now());
  }
  return fallback ?? DateTime.now();
}

Map<String, dynamic> _productToMap(Product p) => {
      'name': p.name,
      'description': p.description,
      'barcode': p.barcode,
      'imageUrl': p.imageUrl,
      'type': p.type.name,
      'categoryId': p.categoryId,
      'purchasePrice': p.purchasePrice,
      'sellingPrice': p.sellingPrice,
      'minSellingPrice': p.minSellingPrice,
      'maxSellingPrice': p.maxSellingPrice,
      'unit': p.unit,
      'quantity': p.quantity,
      'safetyStock': p.safetyStock,
      'locationId': p.locationId,
      'isComposed': p.isComposed,
      'components': p.components
          ?.map((c) => {
                'productId': c.productId,
                'quantity': c.quantity,
                'unit': c.unit,
              })
          .toList(),
      'createdAt': p.createdAt.millisecondsSinceEpoch,
      'updatedAt': p.updatedAt.millisecondsSinceEpoch,
    };

Product? _productFromMap(Map<String, dynamic> map, {required String id}) {
  final typeName = map['type'] as String?;
  if (typeName == null) return null;
  return Product(
    id: id,
    name: map['name'] as String? ?? '',
    description: map['description'] as String?,
    barcode: map['barcode'] as String?,
    imageUrl: map['imageUrl'] as String?,
    type: ProductType.values.firstWhere(
      (x) => x.name == typeName,
      orElse: () => ProductType.produit,
    ),
    categoryId: map['categoryId'] as String? ?? '',
    purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ?? 0,
    sellingPrice: (map['sellingPrice'] as num?)?.toDouble() ?? 0,
    minSellingPrice: (map['minSellingPrice'] as num?)?.toDouble(),
    maxSellingPrice: (map['maxSellingPrice'] as num?)?.toDouble(),
    unit: map['unit'] as String? ?? 'unite',
    quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
    safetyStock: (map['safetyStock'] as num?)?.toDouble() ?? 0,
    locationId: map['locationId'] as String?,
    isComposed: map['isComposed'] as bool? ?? false,
    components: (map['components'] as List<dynamic>?)
        ?.map((x) => x as Map<String, dynamic>)
        .map(
          (x) => ProductComponent(
            productId: x['productId'] as String? ?? '',
            quantity: (x['quantity'] as num?)?.toDouble() ?? 0,
            unit: x['unit'] as String?,
          ),
        )
        .toList(),
    createdAt: _readDate(map, 'createdAt'),
    updatedAt: _readDate(map, 'updatedAt'),
  );
}

Map<String, dynamic> _categoryToMap(Category c) => {
      'name': c.name,
      'description': c.description,
      'createdAt': c.createdAt.millisecondsSinceEpoch,
    };

Category? _categoryFromMap(Map<String, dynamic> map, {required String id}) =>
    Category(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      createdAt: _readDate(map, 'createdAt'),
    );

Map<String, dynamic> _invoiceToMap(Invoice i) => {
      'invoiceNumber': i.invoiceNumber,
      'items': i.items
          .map(
            (x) => {
              'productId': x.productId,
              'productName': x.productName,
              'quantity': x.quantity,
              'unitPrice': x.unitPrice,
              'discount': x.discount,
            },
          )
          .toList(),
      'tax': i.tax,
      'discount': i.discount,
      'paymentMethod': i.paymentMethod.name,
      'status': i.status.name,
      'customerName': i.customerName,
      'customerPhone': i.customerPhone,
      'cashierId': i.cashierId,
      'cashierName': i.cashierName,
      'locationId': i.locationId,
      'isCredit': i.isCredit,
      'amountPaid': i.amountPaid,
      'createdAt': i.createdAt.millisecondsSinceEpoch,
      'paidAt': i.paidAt?.millisecondsSinceEpoch,
    };

Invoice? _invoiceFromMap(Map<String, dynamic> map, {required String id}) {
  final pmName = map['paymentMethod'] as String?;
  if (pmName == null) return null;
  final statusName = map['status'] as String? ?? InvoiceStatus.payee.name;
  final items = (map['items'] as List<dynamic>? ?? <dynamic>[])
      .map((x) => x as Map<String, dynamic>)
      .map(
        (x) => InvoiceItem(
          productId: x['productId'] as String? ?? '',
          productName: x['productName'] as String? ?? '',
          quantity: (x['quantity'] as num?)?.toDouble() ?? 0,
          unitPrice: (x['unitPrice'] as num?)?.toDouble() ?? 0,
          discount: (x['discount'] as num?)?.toDouble() ?? 0,
        ),
      )
      .toList();

  return Invoice(
    id: id,
    invoiceNumber: map['invoiceNumber'] as String?,
    items: items,
    tax: (map['tax'] as num?)?.toDouble() ?? 0,
    discount: (map['discount'] as num?)?.toDouble() ?? 0,
    paymentMethod: PaymentMethod.values.firstWhere(
      (x) => x.name == pmName,
      orElse: () => PaymentMethod.espece,
    ),
    status: InvoiceStatus.values.firstWhere(
      (x) => x.name == statusName,
      orElse: () => InvoiceStatus.payee,
    ),
    customerName: map['customerName'] as String?,
    customerPhone: map['customerPhone'] as String?,
    cashierId: map['cashierId'] as String? ?? '',
    cashierName: map['cashierName'] as String? ?? '',
    locationId: map['locationId'] as String?,
    isCredit: map['isCredit'] as bool? ?? false,
    amountPaid: (map['amountPaid'] as num?)?.toDouble(),
    createdAt: _readDate(map, 'createdAt'),
    paidAt: map['paidAt'] == null ? null : _readDate(map, 'paidAt'),
  );
}

Map<String, dynamic> _userToMap(User u) => {
      'name': u.name,
      'email': u.email,
      'phone': u.phone,
      'role': u.role.name,
      'locationId': u.locationId,
      'isActive': u.isActive,
      'createdAt': u.createdAt.millisecondsSinceEpoch,
    };

User? _userFromMap(Map<String, dynamic> map, {required String id}) {
  final roleName = map['role'] as String?;
  if (roleName == null) return null;
  return User(
    id: id,
    name: map['name'] as String? ?? '',
    email: map['email'] as String? ?? '',
    phone: map['phone'] as String?,
    role: UserRole.values.firstWhere(
      (x) => x.name == roleName,
      orElse: () => UserRole.vendeur,
    ),
    locationId: map['locationId'] as String?,
    isActive: map['isActive'] as bool? ?? true,
    createdAt: _readDate(map, 'createdAt'),
  );
}

Map<String, dynamic> _stockMovementToMap(StockMovement m) => {
      'productId': m.productId,
      'type': m.type.name,
      'quantity': m.quantity,
      'previousQuantity': m.previousQuantity,
      'newQuantity': m.newQuantity,
      'sourceLocationId': m.sourceLocationId,
      'destinationLocationId': m.destinationLocationId,
      'reason': m.reason,
      'userId': m.userId,
      'date': m.date.millisecondsSinceEpoch,
      'reference': m.reference,
    };

StockMovement? _stockMovementFromMap(Map<String, dynamic> map,
    {required String id}) {
  final typeName = map['type'] as String?;
  if (typeName == null) return null;
  return StockMovement(
    id: id,
    productId: map['productId'] as String? ?? '',
    type: MovementType.values.firstWhere(
      (x) => x.name == typeName,
      orElse: () => MovementType.entree,
    ),
    quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
    previousQuantity: (map['previousQuantity'] as num?)?.toDouble() ?? 0,
    newQuantity: (map['newQuantity'] as num?)?.toDouble() ?? 0,
    sourceLocationId: map['sourceLocationId'] as String?,
    destinationLocationId: map['destinationLocationId'] as String?,
    reason: map['reason'] as String?,
    userId: map['userId'] as String? ?? '',
    date: _readDate(map, 'date'),
    reference: map['reference'] as String?,
  );
}

Map<String, dynamic> _locationToMap(Location l) => {
      'name': l.name,
      'address': l.address,
      'isActive': l.isActive,
    };

Location? _locationFromMap(Map<String, dynamic> map, {required String id}) =>
    Location(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String?,
      isActive: map['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _cashRegisterToMap(CashRegister r) => {
      'locationId': r.locationId,
      'openingAmount': r.openingAmount,
      'closingAmount': r.closingAmount,
      'cashierId': r.cashierId,
      'openedAt': r.openedAt.millisecondsSinceEpoch,
      'closedAt': r.closedAt?.millisecondsSinceEpoch,
      'totalSales': r.totalSales,
      'totalExpenses': r.totalExpenses,
      'totalCredits': r.totalCredits,
      'totalReceipts': r.totalReceipts,
    };

CashRegister? _cashRegisterFromMap(Map<String, dynamic> map,
        {required String id}) =>
    CashRegister(
      id: id,
      locationId: map['locationId'] as String? ?? '',
      openingAmount: (map['openingAmount'] as num?)?.toDouble() ?? 0,
      closingAmount: (map['closingAmount'] as num?)?.toDouble(),
      cashierId: map['cashierId'] as String? ?? '',
      openedAt: _readDate(map, 'openedAt'),
      closedAt: map['closedAt'] == null ? null : _readDate(map, 'closedAt'),
      totalSales: (map['totalSales'] as num?)?.toDouble() ?? 0,
      totalExpenses: (map['totalExpenses'] as num?)?.toDouble() ?? 0,
      totalCredits: (map['totalCredits'] as num?)?.toDouble() ?? 0,
      totalReceipts: (map['totalReceipts'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _creditToMap(Credit c) => {
      'customerName': c.customerName,
      'customerPhone': c.customerPhone,
      'amount': c.amount,
      'amountPaid': c.amountPaid,
      'invoiceId': c.invoiceId,
      'date': c.date.millisecondsSinceEpoch,
      'dueDate': c.dueDate?.millisecondsSinceEpoch,
      'isCustomerCredit': c.isCustomerCredit,
    };

Credit? _creditFromMap(Map<String, dynamic> map, {required String id}) =>
    Credit(
      id: id,
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String?,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0,
      invoiceId: map['invoiceId'] as String?,
      date: _readDate(map, 'date'),
      dueDate: map['dueDate'] == null ? null : _readDate(map, 'dueDate'),
      isCustomerCredit: map['isCustomerCredit'] as bool? ?? true,
    );

Map<String, dynamic> _expenseToMap(Expense e) => {
      'description': e.description,
      'amount': e.amount,
      'category': e.category,
      'userId': e.userId,
      'date': e.date.millisecondsSinceEpoch,
    };

Expense? _expenseFromMap(Map<String, dynamic> map, {required String id}) =>
    Expense(
      id: id,
      description: map['description'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      category: map['category'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      date: _readDate(map, 'date'),
    );
