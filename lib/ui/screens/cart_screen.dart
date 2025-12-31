import 'package:dak_louk/domain/services/cart_service.dart';
import 'package:dak_louk/ui/widgets/appbar.dart';
import 'package:dak_louk/ui/screens/checkout_screen.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Appbar(title: 'Cart'),
      ),
      body: FutureBuilder(
        future: _cartService.getCarts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No carts found.'));
          }
          final carts = snapshot.data!;
          return ListView.builder(
            itemCount: carts.length,
            itemBuilder: (context, index) {
              final cart = carts[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(cart: cart),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Dismissible(
                      key: Key(cart.id.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await _cartService.deleteCart(cart.id);
                        setState(() {});
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),

                      child: ListTile(
                        leading: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image(
                              image: AssetImage(cart.productImageUrl ?? ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          cart.productName ?? '',
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          cart.productPrice.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
