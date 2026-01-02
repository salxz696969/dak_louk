import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/widgets/screens/cart/quantity_chooser.dart';
import 'package:flutter/material.dart';

class CartItem extends StatefulWidget {
  final CartItemVM item;
  final Function(int) onRemoved;
  final Function(int, int) onQuantityChanged;

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
  @override
  void initState() {
    super.initState();
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
                  QuantityChooser(
                    cartId: widget.item.id,
                    quantity: widget.item.quantity,
                    availableQuantity: widget.item.availableQuantity,
                    onQuantityChanged: (cartId, newQuantity) =>
                        widget.onQuantityChanged(cartId, newQuantity),
                    onDelete: (cartId) => widget.onRemoved(cartId),
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
