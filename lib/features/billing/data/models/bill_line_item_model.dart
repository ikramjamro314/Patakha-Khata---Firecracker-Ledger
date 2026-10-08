import 'package:hive/hive.dart';

part 'bill_line_item_model.g.dart';

@HiveType(typeId: 1)
class BillLineItemModel extends HiveObject {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String productName;

  @HiveField(2)
  int priceTierIndex;

  @HiveField(3)
  String priceTierLabel;

  @HiveField(4)
  double unitPrice;

  @HiveField(5)
  int quantity;

  @HiveField(6)
  double lineTotal;

  BillLineItemModel({
    required this.productId,
    required this.productName,
    required this.priceTierIndex,
    required this.priceTierLabel,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });
}
