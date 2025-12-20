import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return BottomAppBar(
      color: Theme.of(context).colorScheme.primary,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _item(icon: Icons.home_filled, index: 0),
          const Spacer(),
          _item(icon: CupertinoIcons.chat_bubble_fill, index: 1),
          const Spacer(),
          _item(icon: Icons.video_collection_rounded, index: 2),
          const Spacer(),
          _item(icon: Icons.person_rounded, index: 3),
        ],
      ),
    );
  }

  Widget _item({required IconData icon, required int index}) {
    final isActive = currentIndex == index;
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: isActive ? 28 : 26),
      onPressed: () => onNavigate(index),
    );
  }
}
