import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patakha_khata/core/constants/app_colors.dart';
import 'package:patakha_khata/core/constants/app_routes.dart';
import 'package:patakha_khata/core/constants/app_strings.dart';
import 'package:patakha_khata/core/providers/app_providers.dart';
import 'package:patakha_khata/core/utils/currency_formatter.dart';
import 'package:patakha_khata/core/utils/haptic_utils.dart';
import 'package:patakha_khata/core/widgets/app_scaffold.dart';
import 'package:patakha_khata/features/billing/presentation/widgets/product_bill_card.dart';
import 'package:patakha_khata/features/products/data/models/product_model.dart';

class NewBillScreen extends ConsumerWidget {
  const NewBillScreen({super.key});

  ProductCardState _stateFor(ProductModel product, DraftBillState draft) {
    final hasLine = draft.lines.any((l) => l.productId == product.id);
    if (hasLine && draft.expandedProductId != product.id) {
      return ProductCardState.done;
    }
    if (draft.expandedProductId == product.id) {
      return ProductCardState.expanded;
    }
    return ProductCardState.collapsed;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsListProvider);
    final draft = ref.watch(draftBillProvider);
    final notifier = ref.read(draftBillProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundSurface,
      appBar: const PkAppBar(title: AppStrings.newBillTitle, showBack: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
              itemCount: products.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: TextField(
                      onChanged: notifier.setCustomerName,
                      decoration: const InputDecoration(
                        hintText: AppStrings.customerOptional,
                        hintStyle: TextStyle(color: AppColors.textMuted),
                        suffixIcon: Icon(
                          Icons.person_outline,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }
                final product = products[index - 1];
                final state = _stateFor(product, draft);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProductBillCard(
                    product: product,
                    state: state,
                    onExpand: () => notifier.expandProduct(product.id),
                    onEdit: () => notifier.editLine(product.id),
                  ),
                );
              },
            ),
          ),
          _StickyFooter(
            itemCount: draft.itemCount,
            total: draft.subtotal,
            onGenerate: draft.lines.isEmpty
                ? null
                : () {
                    HapticUtils.heavy();
                    context.push(AppRoutes.billPreview);
                  },
          ),
        ],
      ),
    );
  }
}

class _StickyFooter extends StatelessWidget {
  const _StickyFooter({
    required this.itemCount,
    required this.total,
    required this.onGenerate,
  });

  final int itemCount;
  final double total;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLavender,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$itemCount ${AppStrings.itemsSelected}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          AppStrings.total,
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          CurrencyFormatter.format(total),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onGenerate,
                icon: const Icon(Icons.receipt_long),
                label: const Text(AppStrings.generateReceipt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
