import 'package:dak_louk/screens/chat_screen.dart';
import 'package:dak_louk/screens/home_screen.dart';
import 'package:dak_louk/screens/live_stream_screen.dart';
import 'package:dak_louk/screens/setting_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final ValueChanged<Widget> onNavigate;

  const Navbar({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).colorScheme.primary,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.home_filled, color: Colors.white, size: 26),
            onPressed: () => onNavigate(const HomeScreen()),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              CupertinoIcons.chat_bubble_fill,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () => onNavigate(const ChatScreen()),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.video_collection_rounded,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () => onNavigate(const LiveStreamScreen()),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 26),
            onPressed: () => onNavigate(const SettingScreen()),
          ),
        ],
      ),
    );
  }
}
