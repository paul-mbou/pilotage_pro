import 'dart:async';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pilotage_pro/data/baas/auth/auth_gateway.dart';
import 'package:pilotage_pro/data/baas/auth/auth_user.dart';
import 'package:pilotage_pro/data/baas/auth/firebase_auth_gateway.dart';
import 'package:pilotage_pro/data/baas/auth/noop_auth_gateway.dart';
import 'package:pilotage_pro/data/baas/backend_type.dart';
import 'package:pilotage_pro/data/baas/database/document_store.dart';
import 'package:pilotage_pro/data/baas/database/firebase_document_store.dart';
import 'package:pilotage_pro/data/baas/database/noop_document_store.dart';
import 'package:pilotage_pro/data/bootstrap/firestore_seed_service.dart';
import 'package:pilotage_pro/data/datasources/local/mock_business_data.dart';
import 'package:pilotage_pro/data/repositories/firestore/firestore_repositories.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==================== NOTIFIERS (Notifier / AsyncNotifier) ====================

class ProductNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() {
    Future<void>.microtask(_hydrate);
    return const [];
  }

  Future<void> _hydrate() async {
    final remote = await ref.read(productRepositoryProvider).getAll();
    state = remote;
  }

  void addProduct(Product product) {
    state = [...state, product];
    unawaited(ref.read(productRepositoryProvider).upsert(product));
  }

  void updateProduct(Product product) {
    state = state.map((p) => p.id == product.id ? product : p).toList();
    unawaited(ref.read(productRepositoryProvider).upsert(product));
  }

  void deleteProduct(String id) {
    state = state.where((p) => p.id != id).toList();
    unawaited(ref.read(productRepositoryProvider).delete(id));
  }

  void updateQuantity(String productId, double newQuantity) {
    state = state
        .map((p) => p.id == productId ? p.copyWith(quantity: newQuantity) : p)
        .toList();
    final updated =
        state.where((p) => p.id == productId).cast<Product?>().firstWhere(
              (p) => p != null,
              orElse: () => null,
            );
    if (updated != null) {
      unawaited(ref.read(productRepositoryProvider).upsert(updated));
    }
  }

  List<Product> getByCategory(String categoryId) =>
      state.where((p) => p.categoryId == categoryId).toList();
  List<Product> getByLocation(String locationId) =>
      state.where((p) => p.locationId == locationId).toList();
  List<Product> search(String query) {
    if (query.isEmpty) return state;
    final q = query.toLowerCase();
    return state
        .where((p) =>
            p.name.toLowerCase().contains(q) || p.barcode?.contains(q) == true)
        .toList();
  }

  List<Product> get lowStock => state.where((p) => p.isLowStock).toList();
  double get totalStockValue => state.fold(0, (sum, p) => sum + p.stockValue);
  double get totalStockValuePV =>
      state.fold(0, (sum, p) => sum + p.stockValuePV);
  double get totalMargin => totalStockValuePV - totalStockValue;
}

class CategoryNotifier extends Notifier<List<Category>> {
  @override
  List<Category> build() {
    Future<void>.microtask(_hydrate);
    return const [];
  }

  Future<void> _hydrate() async {
    final remote = await ref.read(categoryRepositoryProvider).getAll();
    state = remote;
  }

  void add(Category c) {
    state = [...state, c];
    unawaited(ref.read(categoryRepositoryProvider).upsert(c));
  }

  void update(Category c) {
    state = state.map((x) => x.id == c.id ? c : x).toList();
    unawaited(ref.read(categoryRepositoryProvider).upsert(c));
  }

  void delete(String id) {
    state = state.where((x) => x.id != id).toList();
    unawaited(ref.read(categoryRepositoryProvider).delete(id));
  }
}

class InvoiceNotifier extends Notifier<List<Invoice>> {
  @override
  List<Invoice> build() {
    Future<void>.microtask(_hydrate);
    return const [];
  }

  Future<void> _hydrate() async {
    final remote = await ref.read(invoiceRepositoryProvider).getAll();
    state = remote;
  }

  void addInvoice(Invoice invoice) {
    state = [invoice, ...state];
    unawaited(ref.read(invoiceRepositoryProvider).upsert(invoice));
  }

  void updateInvoice(Invoice invoice) {
    state = state.map((i) => i.id == invoice.id ? invoice : i).toList();
    unawaited(ref.read(invoiceRepositoryProvider).upsert(invoice));
  }

  void deleteInvoice(String id) {
    state = state.where((i) => i.id != id).toList();
    unawaited(ref.read(invoiceRepositoryProvider).delete(id));
  }

  List<Invoice> getByDate(DateTime date) => state
      .where((i) =>
          i.createdAt.year == date.year &&
          i.createdAt.month == date.month &&
          i.createdAt.day == date.day)
      .toList();

  List<Invoice> getByLocation(String locationId) =>
      state.where((i) => i.locationId == locationId).toList();
  List<Invoice> getByCashier(String cashierId) =>
      state.where((i) => i.cashierId == cashierId).toList();
  List<Invoice> get pending =>
      state.where((i) => i.status == InvoiceStatus.enAttente).toList();
  List<Invoice> get credits => state.where((i) => i.isCredit).toList();

  double get totalSalesToday {
    final now = DateTime.now();
    return state
        .where((i) =>
            i.createdAt.year == now.year &&
            i.createdAt.month == now.month &&
            i.createdAt.day == now.day &&
            i.status == InvoiceStatus.payee)
        .fold(0, (sum, i) => sum + i.total);
  }

  double get totalSalesMonth {
    final now = DateTime.now();
    return state
        .where((i) =>
            i.createdAt.year == now.year &&
            i.createdAt.month == now.month &&
            i.status == InvoiceStatus.payee)
        .fold(0, (sum, i) => sum + i.total);
  }
}

class StockMovementNotifier extends Notifier<List<StockMovement>> {
  @override
  List<StockMovement> build() {
    Future<void>.microtask(_hydrate);
    return const [];
  }

  Future<void> _hydrate() async {
    final remote = await ref.read(stockMovementRepositoryProvider).getAll();
    state = remote;
  }

  void add(StockMovement m) {
    state = [m, ...state];
    unawaited(ref.read(stockMovementRepositoryProvider).upsert(m));
  }

  List<StockMovement> getByProduct(String productId) =>
      state.where((m) => m.productId == productId).toList();
}

class UserNotifier extends Notifier<List<User>> {
  @override
  List<User> build() {
    Future<void>.microtask(_hydrate);
    return const [];
  }

  Future<void> _hydrate() async {
    final remote = await ref.read(userRepositoryProvider).getAll();
    state = remote;
  }

  void add(User u) {
    state = [...state, u];
    unawaited(ref.read(userRepositoryProvider).upsert(u));
  }

  void update(User u) {
    state = state.map((x) => x.id == u.id ? u : x).toList();
    unawaited(ref.read(userRepositoryProvider).upsert(u));
  }

  void delete(String id) {
    state = state.where((x) => x.id != id).toList();
    unawaited(ref.read(userRepositoryProvider).delete(id));
  }

  void toggleActive(String id) {
    state = state
        .map((x) => x.id == id
            ? User(
                id: x.id,
                name: x.name,
                email: x.email,
                phone: x.phone,
                role: x.role,
                locationId: x.locationId,
                isActive: !x.isActive,
                createdAt: x.createdAt,
              )
            : x)
        .toList();
    final updated = state.where((u) => u.id == id).cast<User?>().firstWhere(
          (u) => u != null,
          orElse: () => null,
        );
    if (updated != null) {
      unawaited(ref.read(userRepositoryProvider).upsert(updated));
    }
  }
}

class LocationNotifier extends Notifier<List<Location>> {
  @override
  List<Location> build() {
    Future<void>.microtask(_hydrate);
    return const [];
  }

  Future<void> _hydrate() async {
    final remote = await ref.read(locationRepositoryProvider).getAll();
    state = remote;
  }

  void add(Location l) {
    state = [...state, l];
    unawaited(ref.read(locationRepositoryProvider).upsert(l));
  }

  void update(Location l) {
    state = state.map((x) => x.id == l.id ? l : x).toList();
    unawaited(ref.read(locationRepositoryProvider).upsert(l));
  }
}

class CashRegisterNotifier extends Notifier<List<CashRegister>> {
  @override
  List<CashRegister> build() {
    Future<void>.microtask(_hydrate);
    return [];
  }

  Future<void> _hydrate() async {
    final remote = await ref.read(cashRegisterRepositoryProvider).getAll();
    if (remote.isNotEmpty) {
      state = remote;
    }
  }

  void open(CashRegister cr) {
    state = [...state, cr];
    unawaited(ref.read(cashRegisterRepositoryProvider).upsert(cr));
  }

  void close(String id, double closingAmount) {
    state = state
        .map((x) => x.id == id
            ? CashRegister(
                id: x.id,
                locationId: x.locationId,
                openingAmount: x.openingAmount,
                closingAmount: closingAmount,
                cashierId: x.cashierId,
                openedAt: x.openedAt,
                closedAt: DateTime.now(),
                totalSales: x.totalSales,
                totalExpenses: x.totalExpenses,
                totalCredits: x.totalCredits,
                totalReceipts: x.totalReceipts,
              )
            : x)
        .toList();
    final updated =
        state.where((x) => x.id == id).cast<CashRegister?>().firstWhere(
              (x) => x != null,
              orElse: () => null,
            );
    if (updated != null) {
      unawaited(ref.read(cashRegisterRepositoryProvider).upsert(updated));
    }
  }

  CashRegister? getCurrent(String locationId) {
    try {
      return state
          .lastWhere((x) => x.locationId == locationId && x.closedAt == null);
    } catch (_) {
      return null;
    }
  }
}

class CreditNotifier extends Notifier<List<Credit>> {
  @override
  List<Credit> build() {
    Future<void>.microtask(_hydrate);
    return const [];
  }

  Future<void> _hydrate() async {
    final remote = await ref.read(creditRepositoryProvider).getAll();
    state = remote;
  }

  void add(Credit c) {
    state = [...state, c];
    unawaited(ref.read(creditRepositoryProvider).upsert(c));
  }

  void update(Credit c) {
    state = state.map((x) => x.id == c.id ? c : x).toList();
    unawaited(ref.read(creditRepositoryProvider).upsert(c));
  }

  List<Credit> get customerCredits =>
      state.where((c) => c.isCustomerCredit).toList();
  List<Credit> get supplierDebts =>
      state.where((c) => !c.isCustomerCredit).toList();
  double get totalCustomerCredits =>
      customerCredits.fold(0, (sum, c) => sum + c.remaining);
  double get totalSupplierDebts =>
      supplierDebts.fold(0, (sum, c) => sum + c.remaining);
}

class ExpenseNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() {
    Future<void>.microtask(_hydrate);
    return const [];
  }

  Future<void> _hydrate() async {
    final remote = await ref.read(expenseRepositoryProvider).getAll();
    state = remote;
  }

  void add(Expense e) {
    state = [...state, e];
    unawaited(ref.read(expenseRepositoryProvider).upsert(e));
  }

  void delete(String id) {
    state = state.where((e) => e.id != id).toList();
    unawaited(ref.read(expenseRepositoryProvider).delete(id));
  }

  double get totalMonth {
    final now = DateTime.now();
    return state
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0, (sum, e) => sum + e.amount);
  }
}

class CartNotifier extends Notifier<List<InvoiceItem>> {
  @override
  List<InvoiceItem> build() => [];

  void addItem(Product product, {double quantity = 1, double discount = 0}) {
    final existingIndex =
        state.indexWhere((item) => item.productId == product.id);
    if (existingIndex >= 0) {
      final existing = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        InvoiceItem(
          productId: product.id,
          productName: product.name,
          quantity: existing.quantity + quantity,
          unitPrice: product.sellingPrice,
          discount: discount,
        ),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [
        ...state,
        InvoiceItem(
          productId: product.id,
          productName: product.name,
          quantity: quantity,
          unitPrice: product.sellingPrice,
          discount: discount,
        ),
      ];
    }
  }

  void removeItem(String productId) =>
      state = state.where((item) => item.productId != productId).toList();
  void updateQuantity(String productId, double quantity) {
    state = state
        .map((item) => item.productId == productId
            ? InvoiceItem(
                productId: item.productId,
                productName: item.productName,
                quantity: quantity,
                unitPrice: item.unitPrice,
                discount: item.discount)
            : item)
        .toList();
  }

  void clear() => state = [];
  double get subtotal => state.fold(0, (sum, item) => sum + item.total);
}

class AuthNotifier extends Notifier<User?> {
  static const String _biometricEnabledKey = 'auth.biometric.enabled';
  static const String _lastUserEmailKey = 'auth.last_user_email';

  @override
  User? build() {
    Future<void>.microtask(restoreSession);
    return null;
  }

  void login(User user) => state = user;
  void logout() {
    state = null;
    unawaited(ref.read(authGatewayProvider).signOut());
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final authUser =
        await ref.read(authGatewayProvider).signInWithEmailPassword(
              email: email,
              password: password,
            );
    final matchedUser = await _resolveOrCreateDomainUser(authUser);

    if (matchedUser == null) {
      return false;
    }

    state = matchedUser;
    await _rememberLastEmail(matchedUser.email);
    return true;
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final authUser =
        await ref.read(authGatewayProvider).signUpWithEmailPassword(
              email: email,
              password: password,
              displayName: name,
            );
    if (authUser == null) {
      return false;
    }

    final locations = ref.read(locationProvider);
    final locationId = locations.isNotEmpty ? locations.first.id : null;
    final createdUser = User(
      id: authUser.id,
      name: name.trim(),
      email: authUser.email,
      role: UserRole.vendeur,
      locationId: locationId,
      isActive: true,
    );

    ref.read(userProvider.notifier).add(createdUser);
    state = createdUser;
    await _rememberLastEmail(createdUser.email);
    return true;
  }

  Future<void> loginWithExternalEmail(String email) async {
    final matchedUser =
        await _resolveOrCreateDomainUser(AuthUser(id: email, email: email));
    if (matchedUser != null) {
      state = matchedUser;
      await _rememberLastEmail(matchedUser.email);
      return;
    }
  }

  Future<bool> loginWithGoogle() async {
    final authUser = await ref.read(authGatewayProvider).signInWithGoogle();
    final matchedUser = await _resolveOrCreateDomainUser(authUser);
    if (matchedUser == null) {
      return false;
    }
    state = matchedUser;
    await _rememberLastEmail(matchedUser.email);
    return true;
  }

  Future<bool> loginWithApple() async {
    final authUser = await ref.read(authGatewayProvider).signInWithApple();
    final matchedUser = await _resolveOrCreateDomainUser(authUser);
    if (matchedUser == null) {
      return false;
    }
    state = matchedUser;
    await _rememberLastEmail(matchedUser.email);
    return true;
  }

  Future<void> sendPasswordReset(String email) async {
    await ref.read(authGatewayProvider).sendPasswordResetEmail(email);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<String?> getLastUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUserEmailKey);
  }

  Future<User?> loginWithRememberedUser() async {
    final email = await getLastUserEmail();
    if (email == null) {
      return null;
    }

    final users = ref.read(userProvider);
    final matchedUser = users
        .where((user) => user.email.toLowerCase() == email.toLowerCase())
        .cast<User?>()
        .firstWhere(
          (user) => user != null,
          orElse: () => null,
        );
    if (matchedUser != null) {
      state = matchedUser;
    }
    return matchedUser;
  }

  Future<bool> restoreSession() async {
    final authUser = await ref.read(authGatewayProvider).getCurrentUser();
    final matchedUser = await _resolveOrCreateDomainUser(authUser);
    if (matchedUser == null) {
      return false;
    }
    state = matchedUser;
    await _rememberLastEmail(matchedUser.email);
    return true;
  }

  Future<void> _rememberLastEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUserEmailKey, email);
  }

  Future<User?> _resolveOrCreateDomainUser(AuthUser? authUser) async {
    if (authUser == null) {
      return null;
    }

    var users = ref.read(userProvider);
    final email = authUser.email.toLowerCase();
    final matchedUser =
        users.where((user) => user.isActive).cast<User?>().firstWhere(
              (user) => user?.email.toLowerCase() == email,
              orElse: () => null,
            );
    if (matchedUser != null) {
      return matchedUser;
    }

    final createdUser = User(
      id: authUser.id,
      name: (authUser.displayName?.trim().isNotEmpty ?? false)
          ? authUser.displayName!.trim()
          : authUser.email.split('@').first,
      email: authUser.email,
      role: UserRole.vendeur,
      locationId: ref.read(selectedLocationProvider),
      isActive: true,
    );
    await ref.read(userRepositoryProvider).upsert(createdUser);
    ref.read(userProvider.notifier).add(createdUser);
    return createdUser;
  }
}

class SelectedLocationNotifier extends Notifier<String> {
  @override
  String build() => 'loc_1';

  void select(String locationId) => state = locationId;
}

/// Remplace l’ancien [StateProvider] pour le thème (même usage : [setMode]).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) => state = mode;
}

/// Chiffre d’affaires mensuel (mock) — [AsyncNotifier] prêt pour un futur
/// chargement réseau.
class MonthlyRevenueNotifier extends AsyncNotifier<List<MonthlyRevenue>> {
  @override
  Future<List<MonthlyRevenue>> build() async {
    await Future<void>.delayed(Duration.zero);
    return List<MonthlyRevenue>.from(mockMonthlyRevenue);
  }
}

// ==================== PROVIDERS ====================

final productProvider =
    NotifierProvider<ProductNotifier, List<Product>>(ProductNotifier.new);
final categoryProvider =
    NotifierProvider<CategoryNotifier, List<Category>>(CategoryNotifier.new);
final invoiceProvider =
    NotifierProvider<InvoiceNotifier, List<Invoice>>(InvoiceNotifier.new);
final stockMovementProvider =
    NotifierProvider<StockMovementNotifier, List<StockMovement>>(
        StockMovementNotifier.new);
final userProvider =
    NotifierProvider<UserNotifier, List<User>>(UserNotifier.new);
final locationProvider =
    NotifierProvider<LocationNotifier, List<Location>>(LocationNotifier.new);
final cashRegisterProvider =
    NotifierProvider<CashRegisterNotifier, List<CashRegister>>(
        CashRegisterNotifier.new);
final creditProvider =
    NotifierProvider<CreditNotifier, List<Credit>>(CreditNotifier.new);
final expenseProvider =
    NotifierProvider<ExpenseNotifier, List<Expense>>(ExpenseNotifier.new);
final cartProvider =
    NotifierProvider<CartNotifier, List<InvoiceItem>>(CartNotifier.new);
final authProvider = NotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
final selectedLocationProvider =
    NotifierProvider<SelectedLocationNotifier, String>(
        SelectedLocationNotifier.new);

// Computed providers
final currentUserProvider = Provider<User?>((ref) => ref.watch(authProvider));
final currentLocationProvider =
    Provider<String>((ref) => ref.watch(selectedLocationProvider));

final productsByLocationProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productProvider);
  final locationId = ref.watch(selectedLocationProvider);
  return products.where((p) => p.locationId == locationId).toList();
});

final lowStockProductsProvider = Provider<List<Product>>((ref) {
  return ref.watch(productProvider).where((p) => p.isLowStock).toList();
});

final todaySalesProvider = Provider<double>(
    (ref) => ref.watch(invoiceProvider.notifier).totalSalesToday);
final monthSalesProvider = Provider<double>(
    (ref) => ref.watch(invoiceProvider.notifier).totalSalesMonth);

final customerCreditsProvider = Provider<List<Credit>>(
    (ref) => ref.watch(creditProvider.notifier).customerCredits);
final supplierDebtsProvider = Provider<List<Credit>>(
    (ref) => ref.watch(creditProvider.notifier).supplierDebts);

final monthlyRevenueProvider =
    AsyncNotifierProvider<MonthlyRevenueNotifier, List<MonthlyRevenue>>(
        MonthlyRevenueNotifier.new);

/// Stockly-style theme: [ThemeMode.system] by default; override in settings.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final baasBackendProvider =
    StateProvider<BaaSBackendType>((_) => BaaSBackendType.firebase);

final authGatewayProvider = Provider<AuthGateway>((ref) {
  final backend = ref.watch(baasBackendProvider);
  switch (backend) {
    case BaaSBackendType.firebase:
      return FirebaseAuthGateway();
    case BaaSBackendType.appwrite:
    case BaaSBackendType.supabase:
      return NoopAuthGateway();
  }
});

final documentStoreProvider = Provider<DocumentStore>((ref) {
  final backend = ref.watch(baasBackendProvider);
  switch (backend) {
    case BaaSBackendType.firebase:
      return FirebaseDocumentStore();
    case BaaSBackendType.appwrite:
    case BaaSBackendType.supabase:
      return NoopDocumentStore();
  }
});

final productRepositoryProvider = Provider<ProductRepository>(
    (ref) => ProductRepository(ref.watch(documentStoreProvider)));
final categoryRepositoryProvider = Provider<CategoryRepository>(
    (ref) => CategoryRepository(ref.watch(documentStoreProvider)));
final invoiceRepositoryProvider = Provider<InvoiceRepository>(
    (ref) => InvoiceRepository(ref.watch(documentStoreProvider)));
final stockMovementRepositoryProvider = Provider<StockMovementRepository>(
    (ref) => StockMovementRepository(ref.watch(documentStoreProvider)));
final userRepositoryProvider = Provider<UserRepository>(
    (ref) => UserRepository(ref.watch(documentStoreProvider)));
final locationRepositoryProvider = Provider<LocationRepository>(
    (ref) => LocationRepository(ref.watch(documentStoreProvider)));
final cashRegisterRepositoryProvider = Provider<CashRegisterRepository>(
    (ref) => CashRegisterRepository(ref.watch(documentStoreProvider)));
final creditRepositoryProvider = Provider<CreditRepository>(
    (ref) => CreditRepository(ref.watch(documentStoreProvider)));
final expenseRepositoryProvider = Provider<ExpenseRepository>(
    (ref) => ExpenseRepository(ref.watch(documentStoreProvider)));

final firestoreSeedServiceProvider = Provider<FirestoreSeedService>(
  (ref) => FirestoreSeedService(
    userRepository: ref.watch(userRepositoryProvider),
    locationRepository: ref.watch(locationRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
  ),
);
