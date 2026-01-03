import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/user/order_service.dart';
import 'package:dak_louk/ui/widgets/common/appbar.dart';
import 'package:dak_louk/ui/widgets/user/checkout/checkout_card.dart';
import 'package:dak_louk/ui/widgets/user/checkout/checkout_form.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartVM> carts;

  const CheckoutScreen({super.key, required this.carts});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  void _handleCompleteOrder(
    String? address,
    String? phone,
    String? notes,
  ) async {
    final dtos = <CreateOrderDTO>[];
    for (final cart in widget.carts) {
      dtos.add(
        CreateOrderDTO(
          merchantId: cart.merchant.id,
          address: address,
          phone: phone,
          notes: notes,
          orderItems: cart.items
              .map(
                (item) => CreateOrderProductDTO(
                  productId: item.productId,
                  quantity: item.quantity,
                ),
              )
              .toList(),
        ),
      );
    }
    await _orderService.createOrders(dtos);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order created successfully')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Appbar(title: 'Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (final cart in widget.carts) ...[
              CheckoutCard(cart: cart),
              const SizedBox(height: 20),
            ],
            CheckoutForm(onComplete: _handleCompleteOrder),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
