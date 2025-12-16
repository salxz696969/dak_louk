import 'package:dak_louk/screens/cart_screen.dart';
import 'package:dak_louk/widgets/navbar.dart';
import 'package:flutter/material.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;

  const BaseScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dak Louk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 28,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BaseScaffold(body: CartScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
      body: body,
      bottomNavigationBar: Navbar(
        onNavigate: (screen) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BaseScaffold(body: screen)),
        ),
      ),
    );
  }
}
