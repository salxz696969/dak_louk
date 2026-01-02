import 'package:flutter/material.dart';
import 'package:dak_louk/core/enums/tabs_enum.dart';

class Navbar extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  final int currentIndex;

  const Navbar({
    super.key,
    required this.onNavigate,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = Tabs.values;

    return BottomAppBar(
      color: Theme.of(context).colorScheme.primary,
      height: 90,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(tabs.length, (index) {
            final tab = tabs[index];
            final isActive = index == currentIndex;

            return InkWell(
              onTap: () => onNavigate(index),
              child: Column(
                children: [
                  Icon(
                    tab.icon,
                    size: 28,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                  ),
                  Text(
                    tab.label,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
