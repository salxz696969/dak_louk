import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/user/live_stream_service.dart';
import 'package:dak_louk/domain/services/user/merchant_service.dart';
import 'package:dak_louk/ui/screens/user/fullscreen_video_screen.dart';
import 'package:flutter/material.dart';

class MerchantLiveStreams extends StatelessWidget {
  final MerchantService _merchantService = MerchantService();
  final int merchantId;
  MerchantLiveStreams({required this.merchantId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MerchantLivestreamsVM>>(
      future: _merchantService.getMerchantLiveStreams(merchantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No posts found.')),
          );
        }
        final liveStreams = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 9 / 16,
          ),
          itemBuilder: (context, index) {
            final liveStream = liveStreams[index];
            return _VideoContainer(livestream: liveStream);
          },
          itemCount: liveStreams.length,
        );
      },
    );
  }
}

class _VideoContainer extends StatelessWidget {
  final MerchantLivestreamsVM livestream;
  final LiveStreamService _liveStreamService = LiveStreamService();

  _VideoContainer({required this.livestream});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenVideoScreen(
              livestream: _liveStreamService.getLiveStreamById(livestream.id),
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Image(
              image: AssetImage(livestream.thumbnailUrl),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${livestream.id} views',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
