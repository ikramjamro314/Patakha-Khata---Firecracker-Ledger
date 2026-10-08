import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patakha_khata/core/constants/app_colors.dart';
import 'package:patakha_khata/core/constants/app_strings.dart';
import 'package:patakha_khata/core/providers/app_providers.dart';
import 'package:patakha_khata/core/widgets/app_scaffold.dart';
import 'package:patakha_khata/features/products/data/models/product_model.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _retailController = TextEditingController();
  final _wholesaleController = TextEditingController();
  final _dealerController = TextEditingController();
  final _stockController = TextEditingController(text: '0');

  String? _imagePath;
  bool _initialized = false;
  bool _isPickingImage = false;

  bool get isEditing => widget.productId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _retailController.dispose();
    _wholesaleController.dispose();
    _dealerController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _loadProduct(ProductModel product) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = product.name;
    _descController.text = product.description;
    _retailController.text = product.retailPrice.toStringAsFixed(0);
    _wholesaleController.text = product.wholesalePrice.toStringAsFixed(0);
    _dealerController.text = product.dealerPrice.toStringAsFixed(0);
    _stockController.text = product.stockQuantity.toString();
    _imagePath = product.localImagePath;
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        setState(() => _isPickingImage = false);
        return;
      }
      final path = await ref
          .read(imageServiceProvider)
          .compressAndSave(File(file.path));
      if (path != null) {
        setState(() => _imagePath = path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final retail = double.tryParse(_retailController.text) ?? 0;
    final wholesale = double.tryParse(_wholesaleController.text) ?? 0;
    final dealer = double.tryParse(_dealerController.text) ?? 0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final desc = _descController.text.trim();

    final String message;
    if (isEditing) {
      final existing = ref
          .read(productRepositoryProvider)
          .getById(widget.productId!);
      if (existing == null) return;
      existing
        ..name = name
        ..description = desc
        ..retailPrice = retail
        ..wholesalePrice = wholesale
        ..dealerPrice = dealer
        ..stockQuantity = stock
        ..localImagePath = _imagePath
        ..updatedAt = DateTime.now();
      await ref.read(productsListProvider.notifier).save(existing);
      message = 'Product updated successfully';
    } else {
      await ref
          .read(productsListProvider.notifier)
          .create(
            name: name,
            description: desc,
            retailPrice: retail,
            wholesalePrice: wholesale,
            dealerPrice: dealer,
            stockQuantity: stock,
            localImagePath: _imagePath,
          );
      message = 'Product created successfully';
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    context.pop();
  }

  Future<void> _delete() async {
    if (!isEditing) return;
    await ref.read(productsListProvider.notifier).delete(widget.productId!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Product deleted successfully',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.unpaidRed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      final product = ref
          .watch(productRepositoryProvider)
          .getById(widget.productId!);
      if (product != null) _loadProduct(product);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: PkAppBar(
        title: isEditing ? AppStrings.editProduct : AppStrings.addProduct,
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.imagePlaceholder,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: _imagePath != null && File(_imagePath!).existsSync()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 48),
                        SizedBox(height: 8),
                        Text(AppStrings.pickImage),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          _Field(label: AppStrings.productName, controller: _nameController),
          _Field(label: AppStrings.description, controller: _descController),
          _Field(
            label: AppStrings.retailPrice,
            controller: _retailController,
            keyboardType: TextInputType.number,
            prefix: AppStrings.rupee,
          ),
          _Field(
            label: AppStrings.wholesalePrice,
            controller: _wholesaleController,
            keyboardType: TextInputType.number,
            prefix: AppStrings.rupee,
          ),
          _Field(
            label: AppStrings.dealerPrice,
            controller: _dealerController,
            keyboardType: TextInputType.number,
            prefix: AppStrings.rupee,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            child: Text(isEditing ? AppStrings.save : AppStrings.saveProduct),
          ),
          if (isEditing) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _delete,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.unpaidRed,
              ),
              child: const Text(AppStrings.deleteProduct),
            ),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.prefix,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(prefixText: prefix),
          ),
        ],
      ),
    );
  }
}
