import 'package:dak_louk/domain/domain.dart';
import 'package:flutter/material.dart';

// Extension to add capitalize method to String
extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class CategoryBar extends StatefulWidget {
  final ValueChanged<String> onCategorySelected;
  const CategoryBar({super.key, required this.onCategorySelected});

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final category = ["All", ...ProductCategory.values.map((e) => e.name)];
    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            for (final label in category) ...[
              ChoiceChip(
                label: Text(label.capitalize()),
                selected: label == selectedCategory,
                onSelected: (_) {
                  setState(() {
                    selectedCategory = label;
                  });
                  widget.onCategorySelected(label);
                },
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}
