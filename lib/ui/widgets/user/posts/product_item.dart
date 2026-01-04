import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_model.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/user/cart_service.dart';
import 'package:dak_louk/ui/widgets/common/media_carousel.dart';
import 'package:flutter/material.dart';

class ProductItem extends StatefulWidget {
  final PostProductVM product;

  const ProductItem({super.key, required this.product});

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: widget.product.medias.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MediaCarousel(
                      medias: widget.product.medias
                          .map(
                            (m) => MediaModel(
                              url: m.url,
                              type: m.type == MediaType.video
                                  ? MediaType.video
                                  : MediaType.image,
                            ),
                          )
                          .toList(),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          // Product Name
          Text(
            widget.product.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Product Price
          Text(
            '\$${widget.product.price}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          // Add to Cart Button
          _AddToCartButton(product: widget.product),
        ],
      ),
    );
  }
}

class _AddToCartButton extends StatefulWidget {
  final PostProductVM product;
  const _AddToCartButton({required this.product});

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  final CartService _cartService = CartService();
  bool isAddedToCart = false;
  @override
  void initState() {
    super.initState();
    isAddedToCart = widget.product.isAddedToCart;
  }

  void onAdd() async {
    try {
      final cart = await _cartService.createCart(
        CreateCartDTO(productId: widget.product.id, quantity: 1),
      );
      if (cart != null) {
        setState(() {
          isAddedToCart = true;
        });
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add to cart')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAddedToCart) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: const Text(
            'Add to Cart',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Added to Cart',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
