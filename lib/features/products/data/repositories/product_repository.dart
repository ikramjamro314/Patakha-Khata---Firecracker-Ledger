import 'package:hive/hive.dart';
import 'package:patakha_khata/features/products/data/models/product_model.dart';
import 'package:uuid/uuid.dart';

class ProductRepository {
  ProductRepository(this._box);

  final Box<ProductModel> _box;
  static const _uuid = Uuid();

  List<ProductModel> getAll() {
    final products = _box.values.toList();
    products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return products;
  }

  ProductModel? getById(String id) => _box.get(id);

  Future<ProductModel> save(ProductModel product) async {
    await _box.put(product.id, product);
    return product;
  }

  Future<ProductModel> create({
    required String name,
    required String description,
    required double retailPrice,
    required double wholesalePrice,
    required double dealerPrice,
    required int stockQuantity,
    String? localImagePath,
  }) async {
    final now = DateTime.now();
    final product = ProductModel(
      id: _uuid.v4(),
      name: name,
      description: description,
      retailPrice: retailPrice,
      wholesalePrice: wholesalePrice,
      dealerPrice: dealerPrice,
      stockQuantity: stockQuantity,
      localImagePath: localImagePath,
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(product.id, product);
    return product;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> seedIfEmpty() async {
    if (_box.isNotEmpty) return;
    final now = DateTime.now();
    final samples = [
      ProductModel(
        id: _uuid.v4(),
        name: '12-Shot Aerial Cake',
        description: 'Multi-color strobe effects',
        retailPrice: 450,
        wholesalePrice: 380,
        dealerPrice: 320,
        stockQuantity: 120,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: _uuid.v4(),
        name: 'Golden Sparklers XL',
        description: '10 per box, 12-inch',
        retailPrice: 120,
        wholesalePrice: 95,
        dealerPrice: 80,
        stockQuantity: 200,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: _uuid.v4(),
        name: 'Thunder Rockets',
        description: 'High altitude boom',
        retailPrice: 250,
        wholesalePrice: 210,
        dealerPrice: 180,
        stockQuantity: 85,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: _uuid.v4(),
        name: 'Red Ground Chakkars',
        description: 'Spinning flower effect',
        retailPrice: 90,
        wholesalePrice: 75,
        dealerPrice: 60,
        stockQuantity: 150,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: _uuid.v4(),
        name: 'Zameen Chakkar Standard',
        description: 'Premium rotating ground firework',
        retailPrice: 120,
        wholesalePrice: 95,
        dealerPrice: 80,
        stockQuantity: 45,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: _uuid.v4(),
        name: 'Sky Shot Rocket (Large)',
        description: 'High altitude aerial burst',
        retailPrice: 250,
        wholesalePrice: 200,
        dealerPrice: 175,
        stockQuantity: 60,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    for (final p in samples) {
      await _box.put(p.id, p);
    }
  }
}
