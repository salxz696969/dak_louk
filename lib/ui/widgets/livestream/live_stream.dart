import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/live_stream_chat_service.dart';
import 'package:dak_louk/ui/widgets/livestream/live_stream_products.dart';
import 'package:dak_louk/ui/widgets/livestream/live_stream_chat.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LiveStream extends StatefulWidget {
  final LiveStreamVM livestream;
  const LiveStream({super.key, required this.livestream});

  @override
  State<LiveStream> createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> {
  late VideoPlayerController _controller;
  final LiveStreamChatService _liveStreamChatService = LiveStreamChatService();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.livestream.streamUrl)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _controller.value.isInitialized
              ? GestureDetector(
                  onTap: _togglePlay,
                  child: VideoPlayer(_controller),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FutureBuilder(
            future: _liveStreamChatService.getAllLiveStreamChatByLiveStreamId(
              widget.livestream.id,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData ||
                  (snapshot.data as List<LiveStreamChatVM>).isEmpty) {
                return const Center(child: Text('No live stream chats found.'));
              } else {
                return LiveStreamChat(
                  liveStreamChats: snapshot.data as List<LiveStreamChatVM>,
                );
              }
            },
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                showDragHandle: true,
                backgroundColor: const Color.fromARGB(255, 20, 20, 20),
                context: context,
                builder: (context) => SizedBox(
                  height: 380,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Featured Products',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        LiveStreamProducts(liveStreamId: widget.livestream.id),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Featured Products',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
