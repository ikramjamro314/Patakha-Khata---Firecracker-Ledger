import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patakha_khata/core/constants/app_colors.dart';
import 'package:patakha_khata/core/constants/app_strings.dart';
import 'package:patakha_khata/core/providers/app_providers.dart';
import 'package:patakha_khata/core/utils/currency_formatter.dart';
import 'package:patakha_khata/core/utils/haptic_utils.dart';
import 'package:patakha_khata/features/products/data/models/product_model.dart';
import 'package:patakha_khata/features/products/domain/entities/price_tier.dart';

enum ProductCardState { collapsed, expanded, done }

class ProductBillCard extends ConsumerWidget {
  const ProductBillCard({
    super.key,
    required this.product,
    required this.state,
    required this.onExpand,
    required this.onEdit,
  });

  final ProductModel product;
  final ProductCardState state;
  final VoidCallback onExpand;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(draftBillProvider);
    final doneLine = draft.lines
        .where((l) => l.productId == product.id)
        .firstOrNull;

    switch (state) {
      case ProductCardState.done:
        return _DoneCard(product: product, line: doneLine!, onEdit: onEdit);
      case ProductCardState.expanded:
        return _ExpandedCard(product: product);
      case ProductCardState.collapsed:
        return _CollapsedCard(product: product, onExpand: onExpand);
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.path, this.size = 64});

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: path != null && File(path!).existsSync()
          ? Image.file(File(path!), fit: BoxFit.cover)
          : const Icon(
              Icons.category,
              color: AppColors.textSecondary,
              size: 32,
            ),
    );
  }
}

class _CollapsedCard extends StatelessWidget {
  const _CollapsedCard({required this.product, required this.onExpand});

  final ProductModel product;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)],
      ),
      child: Row(
        children: [
          _ProductImage(path: product.localImagePath),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${CurrencyFormatter.format(product.retailPrice)}${AppStrings.perPiece}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onExpand,
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedCard extends ConsumerWidget {
  const _ExpandedCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(draftBillProvider);
    final tierIndex = draft.selectedTierIndex;
    final qty = draft.draftQuantity;
    final unitPrice = tierIndex >= 0 ? product.priceForTier(tierIndex) : 0.0;
    final liveTotal = unitPrice * qty;
    final tiers = PriceTier.values;
    final isSelected = draft.lines.any((l) => l.productId == product.id);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(path: product.localImagePath, size: 80),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(3, (i) {
              final selected = tierIndex == i;
              final isDisabled = tierIndex >= 0 && !selected;
              final price = product.priceForTier(i);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                  child: IgnorePointer(
                    ignoring: isDisabled,
                    child: Opacity(
                      opacity: isDisabled ? 0.45 : 1.0,
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.light();
                          ref.read(draftBillProvider.notifier).selectTier(i);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.amber : AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected
                                  ? AppColors.amberDark
                                  : AppColors.border,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                tiers[i].label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                  color: selected
                                      ? AppColors.amberText
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(price),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selected
                                      ? AppColors.amberText
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () =>
                          ref.read(draftBillProvider.notifier).decrementQty(),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '$qty',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      filled: true,
                      onTap: () =>
                          ref.read(draftBillProvider.notifier).incrementQty(),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    AppStrings.liveTotal,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(liveTotal),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isSelected)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticUtils.medium();
                      ref
                          .read(draftBillProvider.notifier)
                          .removeLine(product.id);
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.unpaidRed,
                    ),
                    label: const Text(
                      'Deselect',
                      style: TextStyle(color: AppColors.unpaidRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.unpaidRed),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: tierIndex == -1
                        ? null
                        : () {
                            HapticUtils.medium();
                            ref
                                .read(draftBillProvider.notifier)
                                .addLine(
                                  productId: product.id,
                                  productName: product.name,
                                  tierIndex: tierIndex,
                                  tierLabel: tiers[tierIndex].displayName,
                                  unitPrice: unitPrice,
                                  quantity: qty,
                                );
                          },
                    icon: const Icon(Icons.check),
                    label: const Text('Update'),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: tierIndex == -1
                    ? null
                    : () {
                        HapticUtils.medium();
                        ref
                            .read(draftBillProvider.notifier)
                            .addLine(
                              productId: product.id,
                              productName: product.name,
                              tierIndex: tierIndex,
                              tierLabel: tiers[tierIndex].displayName,
                              unitPrice: unitPrice,
                              quantity: qty,
                            );
                      },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text(AppStrings.addToBill),
              ),
            ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : AppColors.backgroundSurface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 14,
            color: filled ? AppColors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _DoneCard extends StatelessWidget {
  const _DoneCard({
    required this.product,
    required this.line,
    required this.onEdit,
  });

  final ProductModel product;
  final DraftBillLine line;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 4,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.stockGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ProductImage(path: product.localImagePath, size: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.tierGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.tierGreen.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  line.priceTierLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.tierGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${AppStrings.qtyPrefix}${line.quantity}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      CurrencyFormatter.format(line.lineTotal),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.borderLight, height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        return TextButton.icon(
                          onPressed: () {
                            HapticUtils.medium();
                            ref
                                .read(draftBillProvider.notifier)
                                .removeLine(product.id);
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.unpaidRed,
                          ),
                          label: const Text(
                            'Remove',
                            style: TextStyle(
                              color: AppColors.unpaidRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
