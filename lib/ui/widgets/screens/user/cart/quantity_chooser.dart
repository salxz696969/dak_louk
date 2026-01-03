import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class QuantityChooser extends StatefulWidget {
  final int cartId;
  final int quantity;
  final int availableQuantity;
  final Function(int, int) onQuantityChanged;
  final Function(int) onDelete;

  const QuantityChooser({
    super.key,
    required this.cartId,
    required this.quantity,
    required this.availableQuantity,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  State<QuantityChooser> createState() => _QuantityChooserState();
}

class _QuantityChooserState extends State<QuantityChooser> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.quantity;
  }

  void _increase() {
    if (quantity < widget.availableQuantity) {
      setState(() => quantity++);
      widget.onQuantityChanged(widget.cartId, quantity);
    }
  }

  void _decrease() {
    if (quantity > 1) {
      setState(() => quantity--);
      widget.onQuantityChanged(widget.cartId, quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: quantity > 1 ? _decrease : null,
          child: Icon(
            CupertinoIcons.minus_circle_fill,
            size: 28,
            color: quantity > 1
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          quantity.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: quantity < widget.availableQuantity ? _increase : null,
          child: Icon(
            CupertinoIcons.add_circled_solid,
            size: 28,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => widget.onDelete(widget.cartId),
        ),
      ],
    );
  }
}
