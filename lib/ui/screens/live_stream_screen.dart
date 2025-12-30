import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/services/live_stream_service.dart';
import 'package:dak_louk/ui/widgets/live_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final LiveStreamService _liveStreamService = LiveStreamService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LiveStreamModel>>(
      future: _liveStreamService.getAllLiveStreams(20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No live streams found.'));
        }
        final liveStreams = snapshot.data!;
        return PageView.builder(
          itemCount: liveStreams.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            final liveStream = liveStreams[index];
            return LiveStream(livestream: liveStream);
          },
        );
      },
    );
  }
}
