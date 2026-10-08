import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patakha_khata/core/constants/app_colors.dart';
import 'package:patakha_khata/core/constants/app_routes.dart';
import 'package:patakha_khata/core/constants/app_strings.dart';
import 'package:patakha_khata/core/widgets/app_bottom_nav.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    required this.currentTab,
    this.showBottomNav = true,
    this.appBar,
  });

  final Widget body;
  final AppNavTab currentTab;
  final bool showBottomNav;
  final PreferredSizeWidget? appBar;

  void _onTab(BuildContext context, AppNavTab tab) {
    switch (tab) {
      case AppNavTab.bills:
        context.go(AppRoutes.home);
      case AppNavTab.inventory:
        context.go(AppRoutes.products);
      case AppNavTab.history:
        context.go(AppRoutes.history);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: appBar,
      body: body,
      bottomNavigationBar: showBottomNav
          ? AppBottomNav(
              currentTab: currentTab,
              onTabSelected: (tab) => _onTab(context, tab),
            )
          : null,
    );
  }
}

class PkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PkAppBar({
    super.key,
    this.title,
    this.showBack = false,
    this.actions,
    this.leading,
  });

  final String? title;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundSurface,
      elevation: 1,
      shadowColor: const Color(0x0D000000),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.pop(),
            )
          : leading ?? null,
      title: title != null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title!,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: title == AppStrings.appName ? 28 : 16,
                ),
              ),
            )
          : null,
      actions: actions,
    );
  }
}
