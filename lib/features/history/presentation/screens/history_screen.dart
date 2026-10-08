import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patakha_khata/core/constants/app_colors.dart';
import 'package:patakha_khata/core/constants/app_strings.dart';
import 'package:patakha_khata/core/providers/app_providers.dart';
import 'package:patakha_khata/core/widgets/app_bottom_nav.dart';
import 'package:patakha_khata/core/widgets/app_scaffold.dart';
import 'package:patakha_khata/features/home/presentation/widgets/bill_list_tile.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyBillsProvider);
    final notifier = ref.read(historyBillsProvider.notifier);

    return AppScaffold(
      currentTab: AppNavTab.history,
      appBar: const PkAppBar(title: AppStrings.historyTitle),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: AppStrings.searchBills,
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
              onChanged: notifier.setSearch,
            ),
          ),
          Expanded(
            child: state.bills.isEmpty
                ? const Center(
                    child: Text(
                      AppStrings.noBills,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount:
                        state.bills.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.bills.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: state.isLoading
                                ? const CircularProgressIndicator()
                                : TextButton(
                                    onPressed: notifier.loadMore,
                                    child: const Text(AppStrings.loadMore),
                                  ),
                          ),
                        );
                      }
                      final bill = state.bills[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BillListTile(bill: bill),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
