import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:patakha_khata/core/services/image_service.dart';
import 'package:patakha_khata/core/storage/hive_boxes.dart';
import 'package:patakha_khata/features/billing/data/models/bill_model.dart';
import 'package:patakha_khata/features/billing/data/repositories/bill_repository.dart';
import 'package:patakha_khata/features/products/data/models/product_model.dart';
import 'package:patakha_khata/features/products/data/repositories/product_repository.dart';

final imageServiceProvider = Provider<ImageService>((ref) {
  return const ImageService();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final box = Hive.box<ProductModel>(HiveBoxes.products);
  return ProductRepository(box);
});

final billRepositoryProvider = Provider<BillRepository>((ref) {
  final box = Hive.box<BillModel>(HiveBoxes.bills);
  return BillRepository(box);
});

final productsListProvider =
    StateNotifierProvider<ProductsNotifier, List<ProductModel>>((ref) {
  return ProductsNotifier(ref.watch(productRepositoryProvider));
});

class ProductsNotifier extends StateNotifier<List<ProductModel>> {
  ProductsNotifier(this._repo) : super(_repo.getAll());

  final ProductRepository _repo;

  void refresh() => state = _repo.getAll();

  Future<void> save(ProductModel product) async {
    await _repo.save(product);
    refresh();
  }

  Future<void> create({
    required String name,
    required String description,
    required double retailPrice,
    required double wholesalePrice,
    required double dealerPrice,
    required int stockQuantity,
    String? localImagePath,
  }) async {
    await _repo.create(
      name: name,
      description: description,
      retailPrice: retailPrice,
      wholesalePrice: wholesalePrice,
      dealerPrice: dealerPrice,
      stockQuantity: stockQuantity,
      localImagePath: localImagePath,
    );
    refresh();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    refresh();
  }
}

final billsRefreshProvider = StateProvider<int>((ref) => 0);

final homeStatsProvider = Provider<({double dailySales, int pending})>((ref) {
  ref.watch(billsRefreshProvider);
  final repo = ref.watch(billRepositoryProvider);
  return (dailySales: repo.getDailySalesTotal(), pending: repo.getPendingCount());
});

final recentBillsProvider = Provider<List<BillModel>>((ref) {
  ref.watch(billsRefreshProvider);
  return ref.watch(billRepositoryProvider).getRecent(limit: 3);
});

final historyBillsProvider =
    StateNotifierProvider<HistoryBillsNotifier, HistoryBillsState>((ref) {
  return HistoryBillsNotifier(ref.watch(billRepositoryProvider), ref);
});

class HistoryBillsState {
  const HistoryBillsState({
    this.bills = const [],
    this.hasMore = true,
    this.isLoading = false,
    this.searchQuery = '',
  });

  final List<BillModel> bills;
  final bool hasMore;
  final bool isLoading;
  final String searchQuery;

  HistoryBillsState copyWith({
    List<BillModel>? bills,
    bool? hasMore,
    bool? isLoading,
    String? searchQuery,
  }) {
    return HistoryBillsState(
      bills: bills ?? this.bills,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HistoryBillsNotifier extends StateNotifier<HistoryBillsState> {
  HistoryBillsNotifier(this._repo, this._ref)
      : super(const HistoryBillsState()) {
    loadInitial();
  }

  final BillRepository _repo;
  final Ref _ref;
  List<BillModel> _allFiltered = [];

  void loadInitial() {
    _allFiltered = _filter(_repo.getAllNewestFirst());
    state = HistoryBillsState(
      bills: _allFiltered.take(HiveBoxes.historyPageSize).toList(),
      hasMore: _allFiltered.length > HiveBoxes.historyPageSize,
    );
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadInitial();
  }

  List<BillModel> _filter(List<BillModel> bills) {
    final q = state.searchQuery.trim().toLowerCase();
    if (q.isEmpty) return bills;
    return bills
        .where((b) =>
            b.customerName.toLowerCase().contains(q) ||
            b.grandTotal.toString().contains(q))
        .toList();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    final current = state.bills.length;
    final next = _allFiltered.skip(current).take(HiveBoxes.historyPageSize).toList();
    state = state.copyWith(
      bills: [...state.bills, ...next],
      hasMore: current + next.length < _allFiltered.length,
      isLoading: false,
    );
  }

  void notifySaved() {
    _ref.read(billsRefreshProvider.notifier).state++;
    loadInitial();
  }
}

/// Draft bill while creating a new bill.
class DraftBillLine {
  DraftBillLine({
    required this.productId,
    required this.productName,
    required this.priceTierIndex,
    required this.priceTierLabel,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final int priceTierIndex;
  final String priceTierLabel;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;
}

class DraftBillState {
  const DraftBillState({
    this.customerName = '',
    this.lines = const [],
    this.expandedProductId,
    this.selectedTierIndex = -1,
    this.draftQuantity = 1,
  });

  final String customerName;
  final List<DraftBillLine> lines;
  final String? expandedProductId;
  final int selectedTierIndex;
  final int draftQuantity;

  double get subtotal =>
      lines.fold<double>(0, (sum, line) => sum + line.lineTotal);

  int get itemCount => lines.fold<int>(0, (sum, line) => sum + line.quantity);

  DraftBillState copyWith({
    String? customerName,
    List<DraftBillLine>? lines,
    String? expandedProductId,
    bool clearExpanded = false,
    int? selectedTierIndex,
    int? draftQuantity,
  }) {
    return DraftBillState(
      customerName: customerName ?? this.customerName,
      lines: lines ?? this.lines,
      expandedProductId:
          clearExpanded ? null : (expandedProductId ?? this.expandedProductId),
      selectedTierIndex: selectedTierIndex ?? this.selectedTierIndex,
      draftQuantity: draftQuantity ?? this.draftQuantity,
    );
  }
}

final draftBillProvider =
    StateNotifierProvider<DraftBillNotifier, DraftBillState>((ref) {
  return DraftBillNotifier();
});

class DraftBillNotifier extends StateNotifier<DraftBillState> {
  DraftBillNotifier() : super(const DraftBillState());

  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }

  void expandProduct(String productId) {
    if (state.expandedProductId == productId) {
      state = state.copyWith(clearExpanded: true);
    } else {
      final hasExisting = state.lines.any((l) => l.productId == productId);
      if (hasExisting) {
        final existingLine = state.lines.firstWhere((l) => l.productId == productId);
        state = state.copyWith(
          expandedProductId: productId,
          selectedTierIndex: existingLine.priceTierIndex,
          draftQuantity: existingLine.quantity,
          clearExpanded: false,
        );
      } else {
        state = state.copyWith(
          expandedProductId: productId,
          selectedTierIndex: -1,
          draftQuantity: 1,
          clearExpanded: false,
        );
      }
    }
  }

  void collapseAll() {
    state = state.copyWith(clearExpanded: true);
  }

  void selectTier(int index) {
    if (state.selectedTierIndex == index) {
      state = state.copyWith(selectedTierIndex: -1);
    } else {
      state = state.copyWith(selectedTierIndex: index);
    }
  }

  void incrementQty() {
    state = state.copyWith(draftQuantity: state.draftQuantity + 1);
  }

  void decrementQty() {
    if (state.draftQuantity > 1) {
      state = state.copyWith(draftQuantity: state.draftQuantity - 1);
    }
  }

  void addLine({
    required String productId,
    required String productName,
    required int tierIndex,
    required String tierLabel,
    required double unitPrice,
    required int quantity,
  }) {
    final existingIndex = state.lines.indexWhere(
      (l) => l.productId == productId,
    );
    final updated = List<DraftBillLine>.from(state.lines);
    if (existingIndex >= 0) {
      updated[existingIndex] = DraftBillLine(
        productId: productId,
        productName: productName,
        priceTierIndex: tierIndex,
        priceTierLabel: tierLabel,
        unitPrice: unitPrice,
        quantity: quantity,
      );
    } else {
      updated.add(DraftBillLine(
        productId: productId,
        productName: productName,
        priceTierIndex: tierIndex,
        priceTierLabel: tierLabel,
        unitPrice: unitPrice,
        quantity: quantity,
      ));
    }
    state = state.copyWith(lines: updated, clearExpanded: true);
  }

  void removeLine(String productId) {
    final updated = state.lines.where((l) => l.productId != productId).toList();
    state = state.copyWith(lines: updated, clearExpanded: true);
  }

  void editLine(String productId) {
    final line = state.lines.firstWhere((l) => l.productId == productId);
    state = state.copyWith(
      expandedProductId: productId,
      selectedTierIndex: line.priceTierIndex,
      draftQuantity: line.quantity,
    );
  }

  void reset() => state = const DraftBillState();
}

class BillPreviewState {
  const BillPreviewState({
    this.discount = 0,
    this.isPaid = true,
    this.paidAmount = 0.0,
  });

  final double discount;
  final bool isPaid;
  final double paidAmount;

  double grandTotal(double subtotal) {
    final clampedDiscount = discount.clamp(0.0, subtotal);
    return subtotal - clampedDiscount;
  }

  BillPreviewState copyWith({
    double? discount,
    bool? isPaid,
    double? paidAmount,
  }) {
    return BillPreviewState(
      discount: discount ?? this.discount,
      isPaid: isPaid ?? this.isPaid,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}

final billPreviewProvider =
    StateNotifierProvider<BillPreviewNotifier, BillPreviewState>((ref) {
  return BillPreviewNotifier();
});

class BillPreviewNotifier extends StateNotifier<BillPreviewState> {
  BillPreviewNotifier() : super(const BillPreviewState());

  void setDiscount(double value) => state = state.copyWith(discount: value);
  
  void setPaid(bool paid) {
    state = state.copyWith(
      isPaid: paid,
      paidAmount: paid ? 0.0 : state.paidAmount,
    );
  }
  
  void setPaidAmount(double amount) => state = state.copyWith(paidAmount: amount);
  
  void reset() => state = const BillPreviewState();
}
