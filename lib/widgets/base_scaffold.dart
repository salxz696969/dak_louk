import 'package:dak_louk/screens/cart_screen.dart';
import 'package:dak_louk/screens/chat_screen.dart';
import 'package:dak_louk/screens/home_screen.dart';
import 'package:dak_louk/screens/live_stream_screen.dart';
import 'package:dak_louk/screens/setting_screen.dart';
import 'package:dak_louk/widgets/appbar.dart';
import 'package:dak_louk/widgets/navbar.dart';
import 'package:flutter/material.dart';

/// Simple tab scaffold for Home / Chat / Live / Settings.
class BaseScaffold extends StatefulWidget {
  final int initialIndex;

  const BaseScaffold({super.key, this.initialIndex = 0});

  @override
  State<BaseScaffold> createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  static const List<Widget> _tabs = [
    HomeScreen(),
    ChatScreen(),
    LiveStreamScreen(),
    SettingScreen(),
  ];

  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Appbar(
          title: 'Dak Louk',
          icon: Icons.receipt_rounded,
          navigateTo: CartScreen(),
        ),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Navbar(
        currentIndex: _currentIndex,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
