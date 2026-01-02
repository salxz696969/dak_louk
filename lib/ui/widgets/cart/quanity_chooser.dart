import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class QuanityChooser extends StatefulWidget {
  final int quantity;
  final int availableQuantity;
  final Function(int) onQuantityChanged;
  final Function() onDelete;
  final bool isLoading;

  const QuanityChooser({
    super.key,
    required this.quantity,
    required this.availableQuantity,
    required this.onQuantityChanged,
    required this.onDelete,
    this.isLoading = false,
  });

  @override
  State<QuanityChooser> createState() => _QuanityChooserState();
}

class _QuanityChooserState extends State<QuanityChooser> {
  @override
  Widget build(BuildContext context) {
    final canDecrease = !widget.isLoading && widget.quantity > 1;
    final canIncrease = !widget.isLoading && widget.quantity < widget.availableQuantity;

    return Row(
      children: [
        InkWell(
          onTap: canDecrease
              ? () => widget.onQuantityChanged(widget.quantity - 1)
              : null,
          child: Icon(
            CupertinoIcons.minus_circle_fill,
            size: 28,
            color: canDecrease
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          widget.quantity.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: canIncrease
              ? () => widget.onQuantityChanged(widget.quantity + 1)
              : null,
          child: Icon(
            CupertinoIcons.add_circled_solid,
            size: 28,
            color: canIncrease
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        // Delete Button
        IconButton(
          tooltip: 'Remove',
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          onPressed: widget.isLoading ? null : () => widget.onDelete(),
        ),
      ],
    );
  }
}
