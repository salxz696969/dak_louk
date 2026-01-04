import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_model.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaCarousel extends StatefulWidget {
  final List<MediaModel> medias;

  const MediaCarousel({super.key, required this.medias});

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  late final PageController controller;
  int _page = 0;
  final Map<int, VideoPlayerController> _videoControllers = {};

  void _onPageChanged(int i) => setState(() => _page = i);

  @override
  void initState() {
    super.initState();
    controller = PageController();
    _initializeVideoControllers();
  }

  void _initializeVideoControllers() {
    for (int i = 0; i < widget.medias.length; i++) {
      final media = widget.medias[i];
      if (media.type == MediaType.video) {
        final videoController = VideoPlayerController.asset(media.url)
          ..initialize().then((_) {
            setState(() {});
          });
        _videoControllers[i] = videoController;
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: widget.medias.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (_, i) {
                final media = widget.medias[i];

                if (media.type == MediaType.video &&
                    _videoControllers.containsKey(i)) {
                  final videoController = _videoControllers[i]!;
                  return videoController.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: videoController.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(videoController),
                              if (!videoController.value.isPlaying)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      videoController.play();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      videoController.pause();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.pause,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : const Center(child: CircularProgressIndicator());
                } else {
                  return Image.asset(
                    media.url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                }
              },
            ),

            if (widget.medias.length > 1)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_page + 1}/${widget.medias.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
