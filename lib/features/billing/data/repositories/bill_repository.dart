import 'package:hive/hive.dart';
import 'package:patakha_khata/core/storage/hive_boxes.dart';
import 'package:patakha_khata/features/billing/data/models/bill_model.dart';

class BillRepository {
  BillRepository(this._box);

  final Box<BillModel> _box;

  List<BillModel> getAllNewestFirst() {
    final bills = _box.values.toList();
    bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bills;
  }

  List<BillModel> getPage({required int offset, required int limit}) {
    final all = getAllNewestFirst();
    if (offset >= all.length) return [];
    final end = (offset + limit).clamp(0, all.length);
    return all.sublist(offset, end);
  }

  BillModel? getById(String id) => _box.get(id);

  Future<BillModel> save(BillModel bill) async {
    await _box.put(bill.id, bill);
    await _enforceMaxBills();
    return bill;
  }

  Future<void> _enforceMaxBills() async {
    if (_box.length <= HiveBoxes.maxBills) return;
    final sorted = getAllNewestFirst();
    final toRemove = sorted.sublist(HiveBoxes.maxBills);
    for (final bill in toRemove) {
      await _box.delete(bill.id);
    }
  }

  double getDailySalesTotal() {
    final today = DateTime.now();
    return _box.values
        .where((b) =>
            b.createdAt.year == today.year &&
            b.createdAt.month == today.month &&
            b.createdAt.day == today.day)
        .fold<double>(0, (sum, b) => sum + b.grandTotal);
  }

  int getPendingCount() => _box.values.where((b) => !b.isPaid).length;

  List<BillModel> getRecent({int limit = 3}) =>
      getPage(offset: 0, limit: limit);
}
