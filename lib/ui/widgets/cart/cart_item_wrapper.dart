import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/cart_service.dart';
import 'package:dak_louk/ui/widgets/cart/cart_item.dart';
import 'package:flutter/material.dart';

class CartItemWrapper extends StatefulWidget {
  final CartVM cart;
  final Function(int, int) onQuantityChanged;
  final Function(int) onRemoved;

  const CartItemWrapper({
    super.key,
    required this.cart,
    required this.onQuantityChanged,
    required this.onRemoved,
  });

  @override
  State<CartItemWrapper> createState() => _CartItemWrapperState();
}

class _CartItemWrapperState extends State<CartItemWrapper> {
  late List<CartItemVM> items;
  CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    items = List.from(widget.cart.items);
  }

  void _handleItemRemoved(int cartId) {
    widget.onRemoved(cartId);
  }

  void _handlePlaceOrder() {
    // Placeholder handler for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Place order for ${widget.cart.merchant.username}'),
      ),
    );
  }

  double _calculateTotal() {
    return items.fold(
      0.0,
      (total, item) => total + (item.price * item.quantity),
    );
  }

  void _handleQuantityChanged(int cartId, int newQuantity) {
    _cartService.updateCart(cartId, UpdateCartDTO(quantity: newQuantity));
    widget.onQuantityChanged(cartId, newQuantity);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Merchant Header
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    widget.cart.merchant.profileImage,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.cart.merchant.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.store, color: Colors.grey[600], size: 20),
              ],
            ),
          ),

          // Cart Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return CartItem(
                item: items[index],
                onRemoved: (cartId) => _handleItemRemoved(cartId),
                onQuantityChanged: (cartId, newQuantity) =>
                    _handleQuantityChanged(cartId, newQuantity),
              );
            },
          ),

          // Total and Place Order Button
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _handlePlaceOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
