import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patakha_khata/core/constants/app_colors.dart';
import 'package:patakha_khata/core/constants/app_routes.dart';
import 'package:patakha_khata/core/constants/app_strings.dart';
import 'package:patakha_khata/core/providers/app_providers.dart';
import 'package:patakha_khata/core/utils/currency_formatter.dart';
import 'package:patakha_khata/core/utils/haptic_utils.dart';
import 'package:patakha_khata/core/widgets/app_bottom_nav.dart';
import 'package:patakha_khata/core/widgets/app_scaffold.dart';
import 'package:patakha_khata/features/billing/data/models/bill_line_item_model.dart';
import 'package:patakha_khata/features/billing/data/models/bill_model.dart';
import 'package:patakha_khata/features/billing/presentation/widgets/receipt_content_widget.dart';
import 'package:uuid/uuid.dart';

class BillPreviewScreen extends ConsumerStatefulWidget {
  const BillPreviewScreen({super.key});

  @override
  ConsumerState<BillPreviewScreen> createState() => _BillPreviewScreenState();
}

class _BillPreviewScreenState extends ConsumerState<BillPreviewScreen> {
  final _discountController = TextEditingController(text: '0');

  BillModel _buildPreviewBill(DraftBillState draft, BillPreviewState preview) {
    final customer = draft.customerName.trim().isEmpty
        ? AppStrings.walkIn
        : draft.customerName.trim();
    final items = draft.lines
        .map(
          (l) => BillLineItemModel(
            productId: l.productId,
            productName: l.productName,
            priceTierIndex: l.priceTierIndex,
            priceTierLabel: l.priceTierLabel,
            unitPrice: l.unitPrice,
            quantity: l.quantity,
            lineTotal: l.lineTotal,
          ),
        )
        .toList();

    final double discount = preview.discount.clamp(0.0, draft.subtotal);
    final double gTotal = draft.subtotal - discount;
    final double enteredPaid = preview.isPaid ? gTotal : preview.paidAmount;
    final double paidAmt = enteredPaid.clamp(0.0, gTotal);
    final isPaid = preview.isPaid || paidAmt >= gTotal;

    return BillModel(
      id: const Uuid().v4(),
      customerName: customer,
      items: items,
      subtotal: draft.subtotal,
      discount: discount,
      grandTotal: gTotal,
      isPaid: isPaid,
      createdAt: DateTime.now(),
      paidAmount: paidAmt,
    );
  }

  final _paidAmountController = TextEditingController(text: '0');

  @override
  void dispose() {
    _discountController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  Future<void> _saveAndOpenReceipt() async {
    HapticUtils.heavy();
    final draft = ref.read(draftBillProvider);
    final preview = ref.read(billPreviewProvider);
    final bill = _buildPreviewBill(draft, preview);

    await ref.read(billRepositoryProvider).save(bill);
    ref.read(billsRefreshProvider.notifier).state++;
    ref.read(historyBillsProvider.notifier).notifySaved();
    ref.read(draftBillProvider.notifier).reset();
    ref.read(billPreviewProvider.notifier).reset();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Bill created successfully!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    context.go(AppRoutes.receiptPath(bill.id));
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(draftBillProvider);
    final preview = ref.watch(billPreviewProvider);
    final grandTotal = preview.grandTotal(draft.subtotal);
    final previewBill = _buildPreviewBill(draft, preview);

    return AppScaffold(
      currentTab: AppNavTab.bills,
      appBar: const PkAppBar(
        title: AppStrings.billPreviewTitle,
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Center(
            child: ReceiptContentWidget(bill: previewBill, showPaidStamp: false),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: const Text(
              AppStrings.addMoreProducts,
              style: TextStyle(color: AppColors.primary, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.discount,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: AppStrings.rupee,
              hintText: '0.00',
            ),
            onChanged: (v) {
              final parsed = double.tryParse(v) ?? 0;
              ref.read(billPreviewProvider.notifier).setDiscount(parsed);
            },
          ),
          const SizedBox(height: 12),
          _PaymentOption(
            title: AppStrings.paidInFull,
            subtitle: AppStrings.paidInFullSub,
            selected: preview.isPaid,
            highlighted: true,
            onTap: () {
              ref.read(billPreviewProvider.notifier).setPaid(true);
              _paidAmountController.text = '0';
            },
          ),
          const SizedBox(height: 12),
          _PaymentOption(
            title: AppStrings.partialUnpaid,
            subtitle: AppStrings.partialUnpaidSub,
            selected: !preview.isPaid,
            highlighted: false,
            onTap: () {
              ref.read(billPreviewProvider.notifier).setPaid(false);
              final currentAmount = ref.read(billPreviewProvider).paidAmount;
              _paidAmountController.text = currentAmount == 0.0
                  ? ''
                  : currentAmount.toStringAsFixed(0);
            },
          ),
          if (!preview.isPaid) ...[
            const SizedBox(height: 12),
            const Text(
              AppStrings.paidAmount,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _paidAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: AppStrings.rupee,
                hintText: '0.00',
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v) ?? 0.0;
                ref.read(billPreviewProvider.notifier).setPaidAmount(parsed);
              },
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.receiptTotalBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.grandTotal,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  CurrencyFormatter.format(grandTotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saveAndOpenReceipt,
              icon: const Icon(Icons.image_outlined),
              label: const Text(AppStrings.generateReceiptPng),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.highlighted,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: highlighted && selected
              ? AppColors.avatarTan
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlighted && selected ? AppColors.amber : AppColors.border,
            width: highlighted && selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
