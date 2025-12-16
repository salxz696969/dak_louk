import 'package:flutter/material.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    const categories = [
      'All',
      'Music',
      'Gaming',
      'Live',
      'News',
      'Fashion',
      'Learning',
      'Sports',
      'Comedy',
    ];

    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            for (final label in categories) ...[
              ChoiceChip(
                label: Text(label),
                selected: label == 'All', 
                onSelected: (_) {},
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}
