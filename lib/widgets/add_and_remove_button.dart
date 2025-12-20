import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddAndRemoveButton extends StatefulWidget {
  final bool reverseColor;
  const AddAndRemoveButton({super.key, this.reverseColor = false});

  @override
  State<AddAndRemoveButton> createState() => _AddAndRemoveButtonState();
}

class _AddAndRemoveButtonState extends State<AddAndRemoveButton> {
  int quantity = 0;
  bool isAdded = false;

  void onAdd() {
    setState(() {
      isAdded = true;
      quantity = quantity + 1;
    });
  }

  void onRemove() {
    setState(() {
      if (quantity > 0) quantity--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onRemove,
          child: Icon(
            widget.reverseColor
                ? CupertinoIcons.minus_circle_fill
                : Icons.remove_circle_rounded,
            size: 30,
            color: widget.reverseColor
                ? Colors.white
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          quantity.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.reverseColor ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          onTap: onAdd,
          child: Icon(
            widget.reverseColor
                ? CupertinoIcons.add_circled_solid
                : Icons.add_circle_rounded,
            size: 28,
            color: widget.reverseColor
                ? Colors.white
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
