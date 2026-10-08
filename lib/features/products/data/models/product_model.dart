import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  double retailPrice;

  @HiveField(4)
  double wholesalePrice;

  @HiveField(5)
  double dealerPrice;

  @HiveField(6)
  int stockQuantity;

  @HiveField(7)
  String? localImagePath;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.retailPrice,
    required this.wholesalePrice,
    required this.dealerPrice,
    required this.stockQuantity,
    this.localImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  double priceForTier(int tierIndex) {
    switch (tierIndex) {
      case 0:
        return retailPrice;
      case 1:
        return wholesalePrice;
      case 2:
        return dealerPrice;
      default:
        return retailPrice;
    }
  }
}
