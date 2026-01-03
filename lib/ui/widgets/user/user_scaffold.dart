import 'package:dak_louk/ui/screens/user/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:dak_louk/ui/screens/user/home_screen.dart';
import 'package:dak_louk/ui/screens/user/chat_room_screen_.dart';
import 'package:dak_louk/ui/screens/user/live_stream_screen.dart';
import 'package:dak_louk/ui/screens/user/profile_screen.dart';
import 'package:dak_louk/ui/screens/user/cart_screen.dart';
import 'package:dak_louk/ui/widgets/common/appbar.dart';
import 'package:dak_louk/ui/widgets/common/navbar.dart';
import 'package:dak_louk/core/enums/tabs_enum.dart';

/// Simple tab scaffold for Home / Chat / Live / Settings.
class UserScaffold extends StatefulWidget {
  final int initialIndex;

  const UserScaffold({super.key, this.initialIndex = 0});

  @override
  State<UserScaffold> createState() => _UserScaffoldState();
}

class _UserScaffoldState extends State<UserScaffold> {
  static const List<Widget> _tabs = [
    HomeScreen(),
    LiveStreamScreen(),
    OrdersScreen(),
    ChatRoomScreen(),
    ProfileScreen(),
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
          icon: Icons.shopping_cart_rounded,
          navigateTo: CartScreen(),
        ),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Navbar(
        tabs: UserTabs.values
            .map((tab) => NavBarItems(label: tab.label, icon: tab.icon))
            .toList(),
        currentIndex: _currentIndex,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
