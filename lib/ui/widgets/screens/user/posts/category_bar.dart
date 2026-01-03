import 'package:dak_louk/domain/models/models.dart';
import 'package:flutter/material.dart';

// Extension to add capitalize method to String
extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class CategoryBar extends StatefulWidget {
  final ValueChanged<ProductCategory> onCategorySelected;
  const CategoryBar({super.key, required this.onCategorySelected});

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  ProductCategory selectedCategory = ProductCategory.all;

  @override
  Widget build(BuildContext context) {
    final categories = ProductCategory.values;
    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            for (final categoryItem in categories) ...[
              ChoiceChip(
                label: Text(categoryItem.name.capitalize()),
                selected: categoryItem == selectedCategory,
                onSelected: (_) {
                  setState(() {
                    selectedCategory = categoryItem;
                  });
                  widget.onCategorySelected(categoryItem);
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
