import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_management_app/core/constants/route_constants.dart';
import 'package:shop_management_app/presentation/providers/auth_provider.dart';
import 'package:shop_management_app/presentation/screens/auth/login_screen.dart';
import 'package:shop_management_app/presentation/screens/auth/setup_screen.dart';
import 'package:shop_management_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:shop_management_app/presentation/screens/products/products_list_screen.dart';
import 'package:shop_management_app/presentation/screens/products/add_product_screen.dart';
import 'package:shop_management_app/presentation/screens/products/categories_screen.dart';
import 'package:shop_management_app/presentation/screens/products/low_stock_screen.dart';
import 'package:shop_management_app/presentation/screens/sales/sales_list_screen.dart';
import 'package:shop_management_app/presentation/screens/sales/new_invoice_screen.dart';
import 'package:shop_management_app/presentation/screens/purchase/purchase_list_screen.dart';
import 'package:shop_management_app/presentation/screens/purchase/new_purchase_screen.dart';
import 'package:shop_management_app/presentation/screens/parties/parties_list_screen.dart';
import 'package:shop_management_app/presentation/screens/parties/add_party_screen.dart';
import 'package:shop_management_app/presentation/screens/reports/reports_home_screen.dart';
import 'package:shop_management_app/presentation/screens/settings/settings_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteConstants.login,
    redirect: (context, state) async {
      final authService = ref.read(authServiceProvider);
      final isAuthenticated = await authService.isAuthenticated();
      final isOnLoginPage = state.matchedLocation == RouteConstants.login;

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isOnLoginPage) {
        return RouteConstants.login;
      }

      // If authenticated and on login page, redirect to dashboard
      if (isAuthenticated && isOnLoginPage) {
        return RouteConstants.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.setup,
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: RouteConstants.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      
      // Products
      GoRoute(
        path: RouteConstants.products,
        builder: (context, state) => const ProductsListScreen(),
      ),
      GoRoute(
        path: RouteConstants.addProduct,
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: RouteConstants.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: RouteConstants.lowStock,
        builder: (context, state) => const LowStockScreen(),
      ),
      
      // Sales
      GoRoute(
        path: RouteConstants.sales,
        builder: (context, state) => const SalesListScreen(),
      ),
      GoRoute(
        path: RouteConstants.newInvoice,
        builder: (context, state) => const NewInvoiceScreen(),
      ),
      
      // Purchase
      GoRoute(
        path: RouteConstants.purchases,
        builder: (context, state) => const PurchaseListScreen(),
      ),
      GoRoute(
        path: RouteConstants.newPurchase,
        builder: (context, state) => const NewPurchaseScreen(),
      ),
      
      // Parties
      GoRoute(
        path: RouteConstants.parties,
        builder: (context, state) => const PartiesListScreen(),
      ),
      GoRoute(
        path: RouteConstants.addParty,
        builder: (context, state) => const AddPartyScreen(),
      ),
      
      // Reports
      GoRoute(
        path: RouteConstants.reports,
        builder: (context, state) => const ReportsHomeScreen(),
      ),
      
      // Settings
      GoRoute(
        path: RouteConstants.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
