import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddAndRemoveButton extends StatefulWidget {
  final double size;
  final int quantity;

  const AddAndRemoveButton({
    super.key,
    this.size = 30.0,
    required this.quantity,
  });

  @override
  State<AddAndRemoveButton> createState() => _AddAndRemoveButtonState();
}

class _AddAndRemoveButtonState extends State<AddAndRemoveButton> {
  int currentQuantity = 0;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (currentQuantity > 0) {
              setState(() {
                currentQuantity = currentQuantity - 1;
              });
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
          onTap: () {
            setState(() {
              if (currentQuantity < widget.quantity) {
                currentQuantity = currentQuantity + 1;
              }
            });
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
