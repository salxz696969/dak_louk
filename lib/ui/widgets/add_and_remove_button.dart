import 'package:dak_louk/db/dao/cart_dao.dart';
import 'package:dak_louk/models/cart_model.dart';
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
  CartDao cartDao = CartDao();

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
              await cartDao.deleteCart(widget.cart.id);
            } else if (currentQuantity > 1) {
              setState(() {
                currentQuantity = currentQuantity - 1;
              });
              await cartDao.updateCart(
                CartModel(
                  id: widget.cart.id,
                  userId: widget.cart.userId,
                  productId: widget.cart.productId,
                  quantity: currentQuantity,
                  createdAt: widget.cart.createdAt,
                  updatedAt: DateTime.now().toIso8601String(),
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
            if (currentQuantity < widget.cart.product!.quantity) {
              setState(() {
                currentQuantity = currentQuantity + 1;
              });
              await cartDao.updateCart(
                CartModel(
                  id: widget.cart.id,
                  userId: widget.cart.userId,
                  productId: widget.cart.productId,
                  quantity: currentQuantity,
                  createdAt: widget.cart.createdAt,
                  updatedAt: DateTime.now().toIso8601String(),
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
