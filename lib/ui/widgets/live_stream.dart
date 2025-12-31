import 'dart:async';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/domain/services/post_service.dart';
import 'package:dak_louk/ui/widgets/post_slider.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LiveStream extends StatefulWidget {
  final LiveStreamModel livestream;
  const LiveStream({super.key, required this.livestream});

  @override
  State<LiveStream> createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.livestream.url)
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
          child: _LiveStreamChatBox(
            liveStreamChats: widget.livestream.liveStreamChats ?? [],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                showDragHandle: true,
                backgroundColor: Color(0xFF1A1A1A),
                context: context,
                builder: (context) => SizedBox(
                  height: 450,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        const Text(
                          'Featured Products',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                        const SizedBox(height: 20),
                        _FeaturedProduct(liveStreamId: widget.livestream.id),
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

class _LiveStreamChatBox extends StatefulWidget {
  final List<LiveStreamChatModel> liveStreamChats;

  const _LiveStreamChatBox({required this.liveStreamChats});

  @override
  State<_LiveStreamChatBox> createState() => _LiveStreamChatBoxState();
}

class _LiveStreamChatBoxState extends State<_LiveStreamChatBox> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final List<LiveStreamChatModel> _visibleChats = [];

  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.liveStreamChats.isNotEmpty) {
      _startStreaming();
    }
  }

  void _startStreaming() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_index >= widget.liveStreamChats.length) {
        timer.cancel();
        return;
      }

      _visibleChats.insert(0, widget.liveStreamChats[_index]);
      _listKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 300),
      );

      _index++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: 400,
      child: AnimatedList(
        key: _listKey,
        reverse: true,
        initialItemCount: _visibleChats.length,
        itemBuilder: (context, index, animation) {
          final chat = _visibleChats[index];

          return SizeTransition(
            sizeFactor: animation,
            axisAlignment: 1.0,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${chat.ui().username}: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                    TextSpan(
                      text: chat.ui().text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedProduct extends StatelessWidget {
  final int liveStreamId;
  final PostService _postService = PostService();
  _FeaturedProduct({required this.liveStreamId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostModel>>(
      future: _postService.getPostsByLiveStreamId(liveStreamId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found.'));
        } else {
          final posts = snapshot.data!;
          return PostSlider(posts: posts);
        }
      },
    );
  }
}
