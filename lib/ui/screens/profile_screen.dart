import 'dart:async';
import 'package:dak_louk/db/repositories/live_stream_dao.dart';
import 'package:dak_louk/db/repositories/post_dao.dart';
import 'package:dak_louk/models/live_stream_chat_model.dart';
import 'package:dak_louk/models/live_stream_model.dart';
import 'package:dak_louk/models/post_model.dart';
import 'package:dak_louk/ui/screens/chat_screen.dart';
import 'package:dak_louk/ui/screens/product_info_screen.dart';
import 'package:dak_louk/ui/widgets/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String rating;
  final ImageProvider profileImage;
  final String bio;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.rating,
    required this.bio,
    required this.profileImage,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _selectedIndex;
  void onTabSelected(String type) {
    setState(() {
      _selectedIndex = type;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = 'photos';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Appbar(title: widget.username),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: widget.profileImage,
                        radius: 30,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.rating,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen()),
                      );
                    },
                    child: Icon(
                      CupertinoIcons.chat_bubble,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(widget.bio, style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 24),
            _ProfileTabSwitcher(
              selectedIndex: _selectedIndex,
              onTabSelected: onTabSelected,
            ),
            const SizedBox(height: 16),
            _selectedIndex == 'photos'
                ? _PostGrid(userId: widget.userId)
                : _LiveStreamGrid(userId: widget.userId),
          ],
        ),
      ),
    );
  }
}

class _ProfileTabSwitcher extends StatelessWidget {
  final String selectedIndex;
  final void Function(String) onTabSelected;

  const _ProfileTabSwitcher({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              icon: Icons.photo,
              label: 'Photos',
              selected: selectedIndex == 'photos',
              onTap: () => onTabSelected('photos'),
            ),
          ),
          Expanded(
            child: _TabButton(
              icon: Icons.video_library,
              label: 'Live Streams',
              selected: selectedIndex == 'live_streams',
              onTap: () => onTabSelected('live_streams'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: selected ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : primary, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostGrid extends StatelessWidget {
  final int userId;
  const _PostGrid({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostModel>>(
      future: PostDao().getPostsByUserId(userId, 20),
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
        final posts = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (context, index) {
            final post = posts[index];
            return _PhotoContainer(post: post);
          },
          itemCount: posts.length,
        );
      },
    );
  }
}

class _LiveStreamGrid extends StatelessWidget {
  final int userId;
  const _LiveStreamGrid({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LiveStreamModel>>(
      future: LiveStreamDao().getAllLiveStreamsByUserId(userId, 20),
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
  final LiveStreamModel livestream;

  const _VideoContainer({required this.livestream});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenVideo(livestream: livestream),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Image(image: livestream.ui().thumbnail, fit: BoxFit.cover),
          ),

          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
          ),

          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${livestream.view} views',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenVideo extends StatefulWidget {
  final LiveStreamModel livestream;

  const FullScreenVideo({super.key, required this.livestream});

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? Stack(
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  _LiveStreamChatBox(
                    chats: widget.livestream.ui().liveStreamChats,
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _LiveStreamChatBox extends StatefulWidget {
  final List<LiveStreamChatModel> chats;

  const _LiveStreamChatBox({required this.chats});

  @override
  State<_LiveStreamChatBox> createState() => __LiveStreamChatBoxState();
}

class __LiveStreamChatBoxState extends State<_LiveStreamChatBox> {
  late List<LiveStreamChatModel> _messages;
  late Timer _timer;
  final ScrollController _scrollController = ScrollController();

  int _counter = 1;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.chats);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _messages.add(
          LiveStreamChatModel(
            id: DateTime.now().millisecondsSinceEpoch,
            userId: 0,
            liveStreamId: 0,
            text: 'Hello $_counter 👋',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        _counter++;
      });

      // auto scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final chat = _messages[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: chat.text,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PhotoContainer extends StatelessWidget {
  final PostModel post;

  const _PhotoContainer({required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductInfoScreen(post: post),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Image(image: post.ui().images[0], fit: BoxFit.cover),
          ),
          if (post.ui().images.length > 1)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.collections,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
