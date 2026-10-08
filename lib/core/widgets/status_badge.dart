import 'package:flutter/material.dart';
import 'package:patakha_khata/core/constants/app_colors.dart';
import 'package:patakha_khata/core/constants/app_strings.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.isPaid});

  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isPaid ? AppColors.paidGreen : AppColors.unpaidPink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isPaid ? AppStrings.paid : AppStrings.unpaid,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: isPaid ? AppColors.paidGreenText : AppColors.unpaidRed,
        ),
      ),
    );
  }
}
