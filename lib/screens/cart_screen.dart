import 'package:dak_louk/widgets/appbar.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Appbar(title: 'Cart'),
      ),
      body: Center(
        child: Text('This is the Cart Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
