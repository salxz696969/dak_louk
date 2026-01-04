import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant/post_service.dart';
import 'package:dak_louk/ui/widgets/merchant/products/product_item.dart';
import 'package:flutter/material.dart';

class PostItem extends StatefulWidget {
  final PostVM post;

  const PostItem({super.key, required this.post});

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
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            title: const Text('Delete Post'),
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Post'),
                                  content: const Text(
                                    'Are you sure you want to delete this post?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        handleDeletePost();
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Promo Media (display first one)
        if (widget.post.promoMedias?.isNotEmpty ?? false)
          Container(
            height: 300,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.post.promoMedias!.first.url,
                fit: BoxFit.cover,
              ),
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
