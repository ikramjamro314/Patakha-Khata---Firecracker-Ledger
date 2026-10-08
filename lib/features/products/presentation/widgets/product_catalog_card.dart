import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patakha_khata/core/constants/app_colors.dart';
import 'package:patakha_khata/core/constants/app_routes.dart';
import 'package:patakha_khata/core/constants/app_strings.dart';
import 'package:patakha_khata/core/utils/currency_formatter.dart';
import 'package:patakha_khata/features/products/data/models/product_model.dart';

class ProductCatalogCard extends StatelessWidget {
  const ProductCatalogCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Image(path: product.localImagePath),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.more_vert,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PriceChip(
                        label: AppStrings.retail,
                        price: product.retailPrice,
                      ),
                      const SizedBox(height: 8),
                      _PriceChip(
                        label: AppStrings.wholesale,
                        price: product.wholesalePrice,
                      ),
                      const SizedBox(height: 8),
                      _PriceChip(
                        label: AppStrings.dealer,
                        price: product.dealerPrice,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: TextButton.icon(
              onPressed: () =>
                  context.push(AppRoutes.productEditPath(product.id)),
              icon: const Icon(Icons.edit, size: 14, color: AppColors.primary),
              label: const Text(
                AppStrings.edit,
                style: TextStyle(color: AppColors.primary),
              ),
              style: TextButton.styleFrom(alignment: Alignment.centerLeft),
            ),
          ),
        ],
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: path != null && File(path!).existsSync()
          ? Image.file(File(path!), fit: BoxFit.cover)
          : const Icon(Icons.category, size: 36, color: AppColors.textSecondary),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.label, required this.price});

  final String label;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${CurrencyFormatter.format(price)}',
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      ),
    );
  }
}
