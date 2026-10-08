import 'package:flutter/material.dart';
import 'package:patakha_khata/core/constants/app_colors.dart';
import 'package:patakha_khata/core/constants/app_strings.dart';
import 'package:patakha_khata/core/utils/currency_formatter.dart';
import 'package:patakha_khata/core/utils/date_formatter.dart';
import 'package:patakha_khata/features/billing/data/models/bill_model.dart';

class ReceiptContentWidget extends StatelessWidget {
  const ReceiptContentWidget({
    super.key,
    required this.bill,
    this.showPaidStamp = true,
  });

  final BillModel bill;
  final bool showPaidStamp;

  @override
  Widget build(BuildContext context) {
    final String watermarkText;
    final Color watermarkColor;
    if (bill.isPaid) {
      watermarkText = 'PAID';
      watermarkColor = AppColors.paidStamp.withOpacity(0.22);
    } else if (bill.paidAmount > 0) {
      watermarkText = 'BAKAYA';
      watermarkColor = AppColors.amberDark.withOpacity(0.22);
    } else {
      watermarkText = 'UNPAID';
      watermarkColor = AppColors.unpaidRed.withOpacity(0.22);
    }

    return Container(
      width: 358,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 4),
        ],
      ),
      child: Stack(
        children: [
          if (showPaidStamp)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: WatermarkStampPainter(
                    text: watermarkText,
                    color: watermarkColor,
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReceiptHeader(date: bill.createdAt),
              _Metadata(
                customer: bill.customerName,
                date: DateFormatter.billDate(bill.createdAt),
              ),
              _ItemsTable(items: bill.items),
              const Divider(color: AppColors.border, height: 1),
              _TotalsBreakdown(
                subtotal: bill.subtotal,
                discount: bill.discount,
                grandTotal: bill.grandTotal,
                paidAmount: bill.paidAmount,
                isPaid: bill.isPaid,
              ),
              const SizedBox(height: 8),
              _JaggedEdge(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppStrings.developedByReceipt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WatermarkStampPainter extends CustomPainter {
  final String text;
  final Color color;

  WatermarkStampPainter({required this.text, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 50,
          fontWeight: FontWeight.w900,
          letterSpacing: 6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.5);
    canvas.rotate(-0.25);

    // Draw watermark text centered
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    // Draw double stamp border
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final outerRect = Rect.fromLTWH(
      -textPainter.width / 2 - 16,
      -textPainter.height / 2 - 8,
      textPainter.width + 32,
      textPainter.height + 16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(outerRect, const Radius.circular(8)),
      paint,
    );

    final innerRect = Rect.fromLTWH(
      -textPainter.width / 2 - 11,
      -textPainter.height / 2 - 5,
      textPainter.width + 22,
      textPainter.height + 10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(5)),
      paint..strokeWidth = 1.5,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WatermarkStampPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.color != color;
  }
}

class _ReceiptHeader extends StatelessWidget {
  const _ReceiptHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryDeep,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: AppColors.white,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.salesReceipt,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
          const Text(
            AppStrings.wholesaleSubtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormatter.receiptDay(date),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.customer, required this.date});

  final String customer;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.customer,
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
                Text(
                  customer,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  AppStrings.date,
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsTable extends StatelessWidget {
  const _ItemsTable({required this.items});

  final List items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFFEDE6F1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  AppStrings.product,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  AppStrings.qty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  AppStrings.totalCol,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: index > 0
                    ? const Border(
                        top: BorderSide(color: AppColors.borderLight),
                      )
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${CurrencyFormatter.format(item.unitPrice)}/unit',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      CurrencyFormatter.format(item.lineTotal),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TotalsBreakdown extends StatelessWidget {
  const _TotalsBreakdown({
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.paidAmount,
    required this.isPaid,
  });

  final double subtotal;
  final double discount;
  final double grandTotal;
  final double paidAmount;
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    final remaining = (grandTotal - paidAmount).clamp(0.0, double.infinity);
    final showPartialBreakdown = !isPaid || paidAmount < grandTotal;

    return Container(
      color: AppColors.receiptTotalBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (discount > 0 || showPartialBreakdown) ...[
            _RowItem(
              label: AppStrings.subtotal,
              value: CurrencyFormatter.format(subtotal),
              isBold: false,
            ),
            const SizedBox(height: 4),
          ],
          if (discount > 0) ...[
            _RowItem(
              label: AppStrings.discount,
              value: '-${CurrencyFormatter.format(discount)}',
              isBold: false,
              valueColor: AppColors.unpaidRed,
            ),
            const SizedBox(height: 4),
          ],
          _RowItem(
            label: AppStrings.grandTotal,
            value: CurrencyFormatter.format(grandTotal),
            isBold: true,
            fontSize: 16,
            valueFontSize: 18,
          ),
          if (showPartialBreakdown) ...[
            const SizedBox(height: 8),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 8),
            _RowItem(
              label: AppStrings.paidAmount,
              value: CurrencyFormatter.format(paidAmount),
              isBold: false,
            ),
            const SizedBox(height: 4),
            _RowItem(
              label: AppStrings.remainingAmount,
              value: CurrencyFormatter.format(remaining),
              isBold: true,
              valueColor: AppColors.unpaidRed,
            ),
          ],
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.label,
    required this.value,
    required this.isBold,
    this.fontSize = 13,
    this.valueFontSize,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final double fontSize;
  final double? valueFontSize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: fontSize,
      color: AppColors.textPrimary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
            fontSize: valueFontSize ?? fontSize,
            color: valueColor ?? AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _JaggedEdge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 8),
      painter: _JaggedPainter(),
    );
  }
}

class _JaggedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.white;
    const step = 8.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawCircle(Offset(x, 0), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
