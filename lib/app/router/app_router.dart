import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pilotage_pro/core/app_huge_icons.dart';
import 'package:pilotage_pro/core/widgets/h_icon.dart';
import 'package:pilotage_pro/features/auth/presentation/forgot_password_screen.dart';
import 'package:pilotage_pro/features/auth/presentation/login_screen.dart';
import 'package:pilotage_pro/features/auth/presentation/signup_screen.dart';
import 'package:pilotage_pro/features/cash/presentation/cash_management_screen.dart';
import 'package:pilotage_pro/features/dashboard/presentation/dashboard_screen.dart';
import 'package:pilotage_pro/features/financial/presentation/financial_report_screen.dart';
import 'package:pilotage_pro/features/invoice/presentation/invoice_detail_screen.dart';
import 'package:pilotage_pro/features/invoice/presentation/invoice_list_screen.dart';
import 'package:pilotage_pro/features/pos/presentation/pos_screen.dart';
import 'package:pilotage_pro/features/product/presentation/product_detail_screen.dart';
import 'package:pilotage_pro/features/product/presentation/product_list_screen.dart';
import 'package:pilotage_pro/features/settings/presentation/settings_screen.dart';
import 'package:pilotage_pro/features/stock/presentation/stock_entry_screen.dart';
import 'package:pilotage_pro/features/stock/presentation/stock_management_screen.dart';
import 'package:pilotage_pro/features/stock/presentation/stock_movement_screen.dart';
import 'package:pilotage_pro/features/stock/presentation/stock_valuation_screen.dart';
import 'package:pilotage_pro/features/user/presentation/user_management_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/pos',
          builder: (context, state) => const PosScreen(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductListScreen(),
        ),
        GoRoute(
          path: '/products/:id',
          builder: (context, state) =>
              ProductDetailScreen(productId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/stock',
          builder: (context, state) => const StockManagementScreen(),
        ),
        GoRoute(
          path: '/stock/entry',
          builder: (context, state) => const StockEntryScreen(),
        ),
        GoRoute(
          path: '/stock/movement',
          builder: (context, state) => const StockMovementScreen(),
        ),
        GoRoute(
          path: '/stock/valuation',
          builder: (context, state) => const StockValuationScreen(),
        ),
        GoRoute(
          path: '/invoices',
          builder: (context, state) => const InvoiceListScreen(),
        ),
        GoRoute(
          path: '/invoices/:id',
          builder: (context, state) =>
              InvoiceDetailScreen(invoiceId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const FinancialReportScreen(),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => const UserManagementScreen(),
        ),
        GoRoute(
          path: '/cash',
          builder: (context, state) => const CashManagementScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: AppHugeIcons.navDashboard,
      activeIcon: AppHugeIcons.navDashboardAct,
      label: 'Accueil',
      path: '/dashboard',
    ),
    _NavItem(
      icon: AppHugeIcons.navCaisse,
      activeIcon: AppHugeIcons.navCaisseAct,
      label: 'Caisse',
      path: '/pos',
    ),
    _NavItem(
      icon: AppHugeIcons.navStock,
      activeIcon: AppHugeIcons.navStockAct,
      label: 'Stock',
      path: '/stock',
    ),
    _NavItem(
      icon: AppHugeIcons.navVentes,
      activeIcon: AppHugeIcons.navVentesAct,
      label: 'Ventes',
      path: '/invoices',
    ),
    _NavItem(
      icon: AppHugeIcons.navReports,
      activeIcon: AppHugeIcons.navReportsAct,
      label: 'Rapports',
      path: '/reports',
    ),
  ];

  @override
  void didUpdateWidget(covariant AppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    final location = GoRouterState.of(context).uri.toString();
    final index =
        _navItems.indexWhere((item) => location.startsWith(item.path));
    if (index != -1 && index != _selectedIndex) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isFullScreen = location.contains('/products/') ||
        location.contains('/invoices/') ||
        location.contains('/stock/entry') ||
        location.contains('/stock/movement') ||
        location.contains('/stock/valuation');

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: isFullScreen
          ? null
          : NavigationBar(
              labelPadding: EdgeInsets.zero,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
                context.go(_navItems[index].path);
              },
              destinations: _navItems
                  .map(
                    (item) => NavigationDestination(
                      icon: HIcon(item.icon, size: 24),
                      selectedIcon: HIcon(item.activeIcon, size: 24),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _NavItem {
  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });

  final List<List<dynamic>> icon;
  final List<List<dynamic>> activeIcon;
  final String label;
  final String path;
}
