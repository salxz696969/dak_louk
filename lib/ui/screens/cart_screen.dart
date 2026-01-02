import 'package:dak_louk/domain/services/cart_service.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/widgets/appbar.dart';
import 'package:dak_louk/ui/widgets/cart/cart_item_wrapper.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  late Future<List<CartVM>> _cartsFuture;
  List<CartVM> _currentCarts = [];

  @override
  void initState() {
    super.initState();
    _loadCarts();
  }

  void _loadCarts() {
    setState(() {
      _cartsFuture = _cartService.getCarts().then((carts) {
        _currentCarts = carts;
        return carts;
      });
    });
  }

  double _calculateSubTotal(List<CartVM> carts) {
    double total = 0.0;
    for (final cart in carts) {
      for (final item in cart.items) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  void _handlePlaceAllOrder() {
    // Placeholder handler for "Place All Order"
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Placed order for all merchants.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Appbar(title: 'Cart'),
      ),
      body: FutureBuilder<List<CartVM>>(
        future: _cartsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final carts = snapshot.data!;
          _currentCarts = carts;

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(bottom: 100.0, top: 8.0),
                itemCount: carts.length,
                itemBuilder: (context, index) {
                  final cart = carts[index];
                  return CartItemWrapper(cart: cart, onChanged: _loadCarts);
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  minimum: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 20.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sub Total',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '\$${_calculateSubTotal(carts).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: carts.isEmpty
                                ? null
                                : _handlePlaceAllOrder,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Place All Order',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
