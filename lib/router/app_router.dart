import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patakha_khata/core/constants/app_routes.dart';
import 'package:patakha_khata/features/billing/presentation/screens/bill_preview_screen.dart';
import 'package:patakha_khata/features/billing/presentation/screens/new_bill_screen.dart';
import 'package:patakha_khata/features/billing/presentation/screens/receipt_screen.dart';
import 'package:patakha_khata/features/history/presentation/screens/history_screen.dart';
import 'package:patakha_khata/features/home/presentation/screens/home_screen.dart';
import 'package:patakha_khata/features/products/presentation/screens/product_form_screen.dart';
import 'package:patakha_khata/features/products/presentation/screens/products_screen.dart';
import 'package:patakha_khata/features/splash/presentation/screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.newBill,
        builder: (context, state) => const NewBillScreen(),
      ),
      GoRoute(
        path: AppRoutes.billPreview,
        builder: (context, state) => const BillPreviewScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.receipt}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReceiptScreen(billId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.productAdd,
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.productEdit}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductFormScreen(productId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
});
