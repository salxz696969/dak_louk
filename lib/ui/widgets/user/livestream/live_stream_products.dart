import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/user/live_stream_products_service.dart';
import 'package:dak_louk/ui/widgets/user/livestream/live_stream_product_item.dart';
import 'package:flutter/material.dart';

class LiveStreamProducts extends StatelessWidget {
  final int liveStreamId;
  final LiveStreamProductsService _liveStreamProductsService =
      LiveStreamProductsService();
  LiveStreamProducts({super.key, required this.liveStreamId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LiveStreamProductsVM>>(
      future: _liveStreamProductsService.getLiveStreamProductsByLiveStreamId(
        liveStreamId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found.'));
        } else {
          final liveStreamProducts = snapshot.data!;
          return SizedBox(
            height: 300,
            // enough to fit the product card
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: liveStreamProducts.length,
              itemBuilder: (context, index) {
                final product = liveStreamProducts[index];
                return LiveStreamProductItem(product: product);
              },
            ),
          );
        }
      },
    );
  }
}
