import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patakha_khata/core/constants/app_colors.dart';
import 'package:patakha_khata/core/constants/app_routes.dart';
import 'package:patakha_khata/core/constants/app_strings.dart';
import 'package:patakha_khata/core/providers/app_providers.dart';
import 'package:patakha_khata/core/widgets/app_bottom_nav.dart';
import 'package:patakha_khata/core/widgets/app_scaffold.dart';
import 'package:patakha_khata/features/products/presentation/widgets/product_catalog_card.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsListProvider);

    return AppScaffold(
      currentTab: AppNavTab.inventory,
      appBar: const PkAppBar(title: AppStrings.productsTitle, showBack: true),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
            itemCount: products.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.productCatalog,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${products.length} products · ${AppStrings.manageInventory}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ProductCatalogCard(product: products[index - 1]);
            },
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    AppStrings.createNewProduct,
                    style: TextStyle(color: AppColors.white, fontSize: 12),
                  ),
                ),
                FloatingActionButton(
                  onPressed: () => context.push(AppRoutes.productAdd),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
