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
      height: 70,
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0, left: 24.0, top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => onNavigate(0),
              child: Icon(
                currentIndex == 0 ? Icons.home_filled : CupertinoIcons.home,
                color: Colors.white,
                size: 28,
              ),
            ),
            InkWell(
              onTap: () => onNavigate(1),
              child: Icon(
                currentIndex == 1
                    ? CupertinoIcons.chat_bubble_fill
                    : CupertinoIcons.chat_bubble,
                color: Colors.white,
                size: 28,
              ),
            ),
            InkWell(
              onTap: () => onNavigate(2),
              child: Icon(
                currentIndex == 2
                    ? Icons.video_collection_rounded
                    : Icons.video_collection_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            InkWell(
              onTap: () => onNavigate(3),
              child: Icon(
                currentIndex == 3 ? Icons.settings : Icons.settings_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
