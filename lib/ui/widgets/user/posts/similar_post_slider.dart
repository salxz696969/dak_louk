import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_model.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/screens/user/post_detail_screen.dart';
import 'package:dak_louk/ui/widgets/common/media_carousel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostSlider extends StatefulWidget {
  final List<PostVM> posts;

  const PostSlider({super.key, required this.posts});

  @override
  State<PostSlider> createState() => _PostSliderState();
}

class _PostSliderState extends State<PostSlider> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: PageView.builder(
          controller: _controller,
          padEnds: false,
          itemCount: widget.posts.length,
          itemBuilder: (context, index) {
            final post = widget.posts[index];
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: _SimilarItemCard(post: post),
            );
          },
        ),
      ),
    );
  }
}

class _SimilarItemCard extends StatefulWidget {
  final PostVM post;

  const _SimilarItemCard({required this.post});

  @override
  State<_SimilarItemCard> createState() => _SimilarItemCardState();
}

class _SimilarItemCardState extends State<_SimilarItemCard> {
  bool isAdded = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postId: widget.post.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  MediaCarousel(
                    medias: widget.post.promoMedias!
                        .map(
                          (m) => MediaModel(
                            url: m.url,
                            type: m.mediaType == 'video'
                                ? MediaType.video
                                : MediaType.image,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage(
                          widget.post.merchant.profileImage,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.merchant.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Text(
                                widget.post.merchant.rating.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[200],
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.post.caption ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
