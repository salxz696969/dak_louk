import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/widgets/common/appbar.dart';
import 'package:dak_louk/ui/widgets/user/merchant_profile/merchant_info.dart';
import 'package:dak_louk/ui/widgets/user/merchant_profile/merchant_livestreams.dart';
import 'package:dak_louk/ui/widgets/user/merchant_profile/merchant_posts.dart';
import 'package:dak_louk/ui/widgets/user/merchant_profile/merchant_products.dart';
import 'package:dak_louk/ui/widgets/user/merchant_profile/merchant_profile_tabs.dart';
import 'package:flutter/material.dart';

enum MerchantProfileTabsEnum {
  posts('Posts', Icons.photo_library),
  liveStreams('Live', Icons.live_tv),
  products('Products', Icons.shopping_bag);

  final String label;
  final IconData icon;

  const MerchantProfileTabsEnum(this.label, this.icon);
}

class MerchantProfileScreen extends StatefulWidget {
  final MerchantVM merchant;

  const MerchantProfileScreen({super.key, required this.merchant});

  @override
  State<MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<MerchantProfileScreen> {
  late MerchantProfileTabsEnum selectedTab;
  void onTabSelected(MerchantProfileTabsEnum tab) {
    setState(() {
      selectedTab = tab;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedTab = MerchantProfileTabsEnum.posts;
  }

  @override
  Widget build(BuildContext context) {
    final merchant = widget.merchant;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Appbar(title: merchant.username),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            MerchantInfo(merchant: merchant),
            const SizedBox(height: 24),

            MerchantProfileTabs(
              selectedTab: selectedTab,
              onTabSelected: (tab) => onTabSelected(tab),
            ),

            const SizedBox(height: 16),

            switch (selectedTab) {
              MerchantProfileTabsEnum.posts => MerchantPosts(
                merchantId: merchant.id,
              ),

              MerchantProfileTabsEnum.liveStreams => MerchantLiveStreams(
                merchantId: merchant.id,
              ),

              MerchantProfileTabsEnum.products => MerchantProducts(
                merchantId: merchant.id,
              ), // hook later
            },
          ],
        ),
      ),
    );
  }
}
