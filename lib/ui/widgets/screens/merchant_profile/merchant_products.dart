import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant_service.dart';
import 'package:dak_louk/domain/services/cart_service.dart';
import 'package:flutter/material.dart';

class MerchantProducts extends StatelessWidget {
  final MerchantService _merchantService = MerchantService();
  final int merchantId;
  MerchantProducts({required this.merchantId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MerchantProductsVM>>(
      future: _merchantService.getMerchantProducts(merchantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No products found.')),
          );
        }
        final products = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            return _HorizontalProductCard(product: product);
          },
        );
      },
    );
  }
}

class _HorizontalProductCard extends StatelessWidget {
  final MerchantProductsVM product;

  const _HorizontalProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Implement navigation to product detail if needed
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Square Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors.grey[200],
                width: 80,
                height: 80,
                child: product.image.isNotEmpty
                    ? Image.asset(
                        product.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            // Product name and quantity
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.quantity} left',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _AddToCartButton(
              productId: product.id,
              isAdded: product.isAddedToCart,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatefulWidget {
  final int productId;
  final bool isAdded;
  const _AddToCartButton({
    Key? key,
    required this.productId,
    required this.isAdded,
  }) : super(key: key);

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  final CartService _cartService = CartService();
  bool isAddedToCart = false;

  @override
  void initState() {
    super.initState();
    isAddedToCart = widget.isAdded;
  }

  void _onAddToCart() async {
    try {
      final cart = await _cartService.createCart(
        CreateCartDTO(productId: widget.productId, quantity: 1),
      );
      if (cart != null) {
        setState(() {
          isAddedToCart = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add to cart')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAddedToCart) {
      return SizedBox(
        height: 38,
        child: ElevatedButton(
          onPressed: _onAddToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Add to Cart'),
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
        label: const Text(
          'Added',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
      ),
    );
  }
}
