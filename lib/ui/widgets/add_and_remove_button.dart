import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/domain/services/cart_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddAndRemoveButton extends StatefulWidget {
  final double size;
  final CartModel cart;
  final int baseQuantity;

  const AddAndRemoveButton({
    super.key,
    this.size = 30.0,
    required this.cart,
    required this.baseQuantity,
  });

  @override
  State<AddAndRemoveButton> createState() => _AddAndRemoveButtonState();
}

class _AddAndRemoveButtonState extends State<AddAndRemoveButton> {
  late int currentQuantity;
  CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    currentQuantity = widget.baseQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            if (currentQuantity == 1) {
              setState(() {
                currentQuantity = 0;
              });
              await _cartService.deleteCart(widget.cart.id);
            } else if (currentQuantity > 1) {
              setState(() {
                currentQuantity = currentQuantity - 1;
              });
              await _cartService.updateCart(
                CartModel(
                  id: widget.cart.id,
                  userId: widget.cart.userId,
                  productId: widget.cart.productId,
                  quantity: currentQuantity,
                  createdAt: widget.cart.createdAt,
                  updatedAt: DateTime.now(),
                ),
              );
            }
          },
          child: Icon(
            CupertinoIcons.minus_circle_fill,
            size: widget.size,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          currentQuantity.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          onTap: () async {
            if (currentQuantity < widget.cart.quantity) {
              setState(() {
                currentQuantity = currentQuantity + 1;
              });
              await _cartService.updateCart(
                CartModel(
                  id: widget.cart.id,
                  userId: widget.cart.userId,
                  productId: widget.cart.productId,
                  quantity: currentQuantity,
                  createdAt: widget.cart.createdAt,
                  updatedAt: DateTime.now(),
                ),
              );
            }
          },
          child: Icon(
            CupertinoIcons.add_circled_solid,
            size: widget.size,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
