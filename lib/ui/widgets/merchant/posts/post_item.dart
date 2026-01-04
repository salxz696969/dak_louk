import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_model.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant/post_service.dart';
import 'package:dak_louk/ui/widgets/common/media_carousel.dart';
import 'package:dak_louk/ui/widgets/merchant/posts/product_item.dart';
import 'package:flutter/material.dart';

class PostItem extends StatefulWidget {
  final PostVM post;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostItem({super.key, required this.post, this.onEdit, this.onDelete});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
  }

  void handleDeletePost() async {
    try {
      await _postService.deletePost(widget.post.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete post')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post Header with timestamp
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Post • ${widget.post.createdAt}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    widget.onEdit?.call();
                  } else if (value == 'delete') {
                    widget.onDelete?.call();
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Promo Media Carousel
        if (widget.post.promoMedias?.isNotEmpty ?? false)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: MediaCarousel(
              medias: widget.post.promoMedias!
                  .map(
                    (media) => MediaModel(
                      url: media.url,
                      type: media.mediaType == 'video'
                          ? MediaType.video
                          : MediaType.image,
                    ),
                  )
                  .toList(),
            ),
          ),

        const SizedBox(height: 16),

        // Post Caption
        if (widget.post.caption?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.post.caption!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

        const SizedBox(height: 16),

        // Products List (Horizontal)
        if (widget.post.products.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Featured Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.post.products.length,
              itemBuilder: (context, index) {
                return ProductItem(product: widget.post.products[index]);
              },
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}
