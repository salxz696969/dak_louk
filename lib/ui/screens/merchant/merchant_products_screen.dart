import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant/product_service.dart';
import 'package:dak_louk/ui/widgets/merchant/products/product_item.dart';
import 'package:dak_louk/ui/widgets/merchant/products/products_create_form.dart';
import 'package:dak_louk/ui/widgets/merchant/products/products_edit_form.dart';
import 'package:flutter/material.dart';

class MerchantProductsScreen extends StatefulWidget {
  const MerchantProductsScreen({super.key});

  @override
  State<MerchantProductsScreen> createState() => _MerchantProductsScreenState();
}

class _MerchantProductsScreenState extends State<MerchantProductsScreen> {
  final ProductService _productService = ProductService();
  List<ProductVM> _products = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductVM>>(
      future: _productService.getAllProductsForCurrentMerchant(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No products found.'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showProductForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                ),
              ],
            ),
          );
        } else {
          _products = snapshot.data!;
          return Stack(
            children: [
              Positioned.fill(
                child: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return MerchantProductItem(
                      product: product,
                      onEdit: () => _showProductForm(context, product: product),
                      onDelete: () => _deleteProduct(product.id, index),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () => _showProductForm(context),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  void _showProductForm(BuildContext context, {ProductVM? product}) {
    showModalBottomSheet(
      enableDrag: true,
      isDismissible: true,
      showDragHandle: true,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: product == null
            ? ProductsCreateForm(
                onSaved: (savedProduct) {
                  setState(() {
                    _products.insert(0, savedProduct);
                  });
                },
              )
            : ProductsUpdateForm(
                product: product,
                onSaved: (savedProduct) {
                  setState(() {
                    final index = _products.indexWhere(
                      (p) => p.id == savedProduct.id,
                    );
                    if (index != -1) {
                      _products[index] = savedProduct;
                    }
                  });
                },
              ),
      ),
    );
  }

  Future<void> _deleteProduct(int productId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _productService.deleteProduct(productId);
        setState(() {
          _products.removeAt(index);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      }
    }
  }
}
