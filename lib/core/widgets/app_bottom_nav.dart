import 'package:flutter/material.dart';
import 'package:patakha_khata/core/constants/app_colors.dart';
import 'package:patakha_khata/core/constants/app_strings.dart';

enum AppNavTab { bills, inventory, history }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final AppNavTab currentTab;
  final ValueChanged<AppNavTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLavender,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.receipt_long_outlined,
              label: AppStrings.navBills,
              isActive: currentTab == AppNavTab.bills,
              onTap: () => onTabSelected(AppNavTab.bills),
            ),
            _NavItem(
              icon: Icons.inventory_2_outlined,
              label: AppStrings.navInventory,
              isActive: currentTab == AppNavTab.inventory,
              onTap: () => onTabSelected(AppNavTab.inventory),
            ),
            _NavItem(
              icon: Icons.history,
              label: AppStrings.navHistory,
              isActive: currentTab == AppNavTab.history,
              onTap: () => onTabSelected(AppNavTab.history),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.amber : AppColors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.amberText : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: isActive ? AppColors.amberText : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
