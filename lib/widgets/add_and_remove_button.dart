import 'package:flutter/material.dart';

class AddAndRemoveButton extends StatefulWidget {
  const AddAndRemoveButton({super.key});

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
            Icons.remove_circle_rounded,
            size: 30,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          quantity.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          onTap: onAdd,
          child: Icon(
            Icons.add_circle_rounded,
            size: 30,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
