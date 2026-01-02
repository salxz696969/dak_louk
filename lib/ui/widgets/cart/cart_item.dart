import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/cart_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CartItem extends StatefulWidget {
  final CartItemVM item;
  final VoidCallback onRemoved;
  final VoidCallback onQuantityChanged;

  const CartItem({
    super.key,
    required this.item,
    required this.onRemoved,
    required this.onQuantityChanged,
  });

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  final CartService _cartService = CartService();
  late int currentQuantity;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentQuantity = widget.item.quantity;
  }

  Future<void> _handleQuantityChange(int newQuantity) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Update quantity
      await _cartService.updateCart(
        widget.item.id,
        UpdateCartDTO(quantity: newQuantity),
      );
      setState(() {
        currentQuantity = newQuantity;
      });
      widget.onQuantityChanged();
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update cart: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                widget.item.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quantity Controls
                  Row(
                    children: [
                      InkWell(
                        onTap: isLoading
                            ? null
                            : () => _handleQuantityChange(currentQuantity - 1),
                        child: Icon(
                          CupertinoIcons.minus_circle_fill,
                          size: 28,
                          color: isLoading
                              ? Colors.grey
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        currentQuantity.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap:
                            isLoading ||
                                currentQuantity >= widget.item.availableQuantity
                            ? null
                            : () => _handleQuantityChange(currentQuantity + 1),
                        child: Icon(
                          CupertinoIcons.add_circled_solid,
                          size: 28,
                          color:
                              isLoading ||
                                  currentQuantity >=
                                      widget.item.availableQuantity
                              ? Colors.grey
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
