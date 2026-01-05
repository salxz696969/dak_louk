import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_model.dart';
import 'package:dak_louk/ui/widgets/merchant/shared/add_products_section.dart';
import 'package:flutter/material.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant/product_service.dart';

/// Shows a bottom sheet for selecting products from the merchant's product catalog.
///
/// Parameters:
/// - [context]: The build context
/// - [productService]: Service for fetching products
/// - [selectedProducts]: List of currently selected products (will be modified)
/// - [onProductsSelected]: Callback when products are selected/deselected
///
/// Returns: Future<void> - completes when the bottom sheet is dismissed

Future<void> showProductSelectorSheet({
  required BuildContext context,
  required ProductService productService,
  required List<AddProductsModel> selectedProducts,
  required Function(List<AddProductsModel>) onProductsSelected,
}) {
  return showModalBottomSheet(
    showDragHandle: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.80,
    ),
    context: context,
    builder: (context) {
      return _ProductSelectorContent(
        productService: productService,
        selectedProducts: selectedProducts,
        onProductsSelected: onProductsSelected,
      );
    },
  );
}

class _ProductSelectorContent extends StatefulWidget {
  final ProductService productService;
  final List<AddProductsModel> selectedProducts;
  final Function(List<AddProductsModel>) onProductsSelected;

  const _ProductSelectorContent({
    required this.productService,
    required this.selectedProducts,
    required this.onProductsSelected,
  });

  @override
  State<_ProductSelectorContent> createState() =>
      _ProductSelectorContentState();
}

class _ProductSelectorContentState extends State<_ProductSelectorContent> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductVM>>(
      future: widget.productService.getAllProductsForCurrentMerchant(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found.'));
        } else {
          final products = snapshot.data!;
          return Stack(
            children: [
              Positioned.fill(
                bottom: 70,
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final alreadySelected = widget.selectedProducts.any(
                      (p) => p.id == product.id,
                    );
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: CheckboxListTile(
                        secondary: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            (product.mediaUrls?.isNotEmpty ?? false)
                                ? product.mediaUrls!.first
                                : 'assets/images/plane.jpg',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                        value: alreadySelected,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true && !alreadySelected) {
                              widget.selectedProducts.add(
                                AddProductsModel(
                                  id: product.id,
                                  name: product.name,
                                  price: product.price,
                                  medias:
                                      product.mediaUrls
                                          ?.map(
                                            (m) => MediaModel(
                                              url: m,
                                              type: MediaType.image,
                                            ),
                                          )
                                          .toList() ??
                                      [],
                                ),
                              );
                            } else if (selected == false && alreadySelected) {
                              widget.selectedProducts.removeWhere(
                                (p) => p.id == product.id,
                              );
                            }
                            widget.onProductsSelected(widget.selectedProducts);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
