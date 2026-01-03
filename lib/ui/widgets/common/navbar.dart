import 'package:flutter/material.dart';

class NavBarItems {
  final String label;
  final IconData icon;

  const NavBarItems({required this.label, required this.icon});
}

class Navbar extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  final int currentIndex;
  final List<NavBarItems> tabs;

  const Navbar({
    super.key,
    required this.onNavigate,
    required this.currentIndex,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {

    return BottomAppBar(
      color: Theme.of(context).colorScheme.primary,
      height: 90,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 12.0,
          top: 12.0,
          bottom: 0,
        ),
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
