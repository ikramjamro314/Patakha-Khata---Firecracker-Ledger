import 'package:hive/hive.dart';
import 'package:patakha_khata/features/billing/data/models/bill_line_item_model.dart';

part 'bill_model.g.dart';

@HiveType(typeId: 2)
class BillModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerName;

  @HiveField(2)
  List<BillLineItemModel> items;

  @HiveField(3)
  double subtotal;

  @HiveField(4)
  double discount;

  @HiveField(5)
  double grandTotal;

  @HiveField(6)
  bool isPaid;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  double paidAmount;

  BillModel({
    required this.id,
    required this.customerName,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.isPaid,
    required this.createdAt,
    required this.paidAmount,
  });
}
