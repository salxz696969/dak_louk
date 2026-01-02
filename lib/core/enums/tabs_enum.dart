import 'package:flutter/material.dart';

enum Tabs {
  home('Home', Icons.home),
  live('Live', Icons.live_tv),
  orders('Orders', Icons.receipt_long),
  chat('Chat', Icons.chat_bubble_outline),
  profile('Profile', Icons.person_outline);

  final String label;
  final IconData icon;

  const Tabs(this.label, this.icon);
}

enum MerchantTabs {
  orders('Orders', Icons.receipt_long),
  products('Products', Icons.shopping_bag),
  posts('Reviews', Icons.photo_library),
  live('Live', Icons.live_tv),
  chat('Chat', Icons.chat_bubble_outline);

  final String label;
  final IconData icon;

  const MerchantTabs(this.label, this.icon);
}
