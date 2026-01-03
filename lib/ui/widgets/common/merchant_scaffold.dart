import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/enums/tabs_enum.dart';
import 'package:dak_louk/ui/screens/auth_screen.dart';
import 'package:dak_louk/ui/widgets/common/merchant_app_bar.dart';
import 'package:dak_louk/ui/widgets/screens/user/merchant_profile/merchant_profile_tabs.dart';
import 'package:flutter/material.dart';
import 'package:dak_louk/ui/widgets/common/appbar.dart';
import 'package:dak_louk/ui/widgets/common/navbar.dart';
import 'package:dak_louk/ui/widgets/screens/merchant/merchant_orders_screen.dart';
import 'package:dak_louk/ui/widgets/screens/merchant/merchant_products_screen.dart';
import 'package:dak_louk/ui/widgets/screens/merchant/merchant_posts_screen.dart';
import 'package:dak_louk/ui/widgets/screens/merchant/merchant_live_screen.dart';
import 'package:dak_louk/ui/widgets/screens/merchant/merchant_chat_screen.dart';

/// Scaffold for merchant tabs: Orders / Products / Posts / Live / Chat.
class MerchantScaffold extends StatefulWidget {
  final int initialIndex;

  const MerchantScaffold({super.key, this.initialIndex = 0});

  @override
  State<MerchantScaffold> createState() => _MerchantScaffoldState();
}

class _MerchantScaffoldState extends State<MerchantScaffold> {
  static const List<Widget> _tabs = [
    MerchantOrdersScreen(),
    MerchantProductsScreen(),
    MerchantPostsScreen(),
    MerchantLiveScreen(),
    MerchantChatScreen(),
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MerchantAppBar(
          title: 'Dak Louk Merchant',
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                AppSession.instance.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Navbar(
        tabs: MerchantTabs.values
            .map((tab) => NavBarItems(label: tab.label, icon: tab.icon))
            .toList(),
        currentIndex: _currentIndex,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
