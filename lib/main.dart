import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:patakha_khata/app.dart';
import 'package:patakha_khata/core/storage/hive_boxes.dart';
import 'package:patakha_khata/features/billing/data/models/bill_line_item_model.dart';
import 'package:patakha_khata/features/billing/data/models/bill_model.dart';
import 'package:patakha_khata/features/products/data/models/product_model.dart';
import 'package:patakha_khata/features/products/data/repositories/product_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(BillLineItemModelAdapter());
  Hive.registerAdapter(BillModelAdapter());

  await Hive.openBox<ProductModel>(HiveBoxes.products);
  await Hive.openBox<BillModel>(HiveBoxes.bills);

  final productRepo = ProductRepository(
    Hive.box<ProductModel>(HiveBoxes.products),
  );
  await productRepo.seedIfEmpty();

  runApp(const ProviderScope(child: PatakhaKhataApp()));
}
