import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/post_like_service.dart';
import 'package:dak_louk/domain/services/post_save_service.dart';
import 'package:dak_louk/ui/widgets/screens/posts/product_item.dart';
import 'package:dak_louk/ui/widgets/screens/posts/username_container.dart';
import 'package:flutter/material.dart';

class PostItem extends StatefulWidget {
  final PostVM post;

  const PostItem({super.key, required this.post});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final PostLikeService _postLikeService = PostLikeService();
  final PostSaveService _postSaveService = PostSaveService();

  late bool isLiked;
  late bool isSaved;
  late int likesCount;
  late int savesCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.isLiked;
    isSaved = widget.post.isSaved;
    likesCount = widget.post.likesCount;
    savesCount = widget.post.savesCount;
  }

  void handlePostLike() async {
    try {
      if (isLiked) {
        await _postLikeService.unlikePost(widget.post.id);
        setState(() {
          isLiked = false;
          likesCount = likesCount > 0 ? likesCount - 1 : 0;
        });
      } else {
        await _postLikeService.likePost(widget.post.id);
        setState(() {
          isLiked = true;
          likesCount = likesCount + 1;
        });
      }
    } catch (e) {
      // Handle error silently or show a snackbar
    }
  }

  void handlePostSave() async {
    try {
      if (isSaved) {
        await _postSaveService.unsavePost(widget.post.id);
        setState(() {
          isSaved = false;
          savesCount = savesCount > 0 ? savesCount - 1 : 0;
        });
      } else {
        await _postSaveService.savePost(widget.post.id);
        setState(() {
          isSaved = true;
          savesCount = savesCount + 1;
        });
      }
    } catch (e) {
      // Handle error silently or show a snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username Container
        UsernameContainer(
          bio: widget.post.merchant.bio,
          merchantId: widget.post.merchantId,
          profile: AssetImage(
            widget.post.merchant.profileImage.isNotEmpty
                ? widget.post.merchant.profileImage
                : 'assets/profiles/profile1.png',
          ),
          username: widget.post.merchant.username,
          rating: widget.post.merchant.rating.toString(),
        ),

        // Promo Media (display first one)
        if (widget.post.promoMedias?.isNotEmpty ?? false)
          Container(
            height: 300,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Background gradient for placeholder
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Positioned.fill(
                    child: Image.asset(
                      widget.post.promoMedias!.first.url,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Play button overlay for videos

                  // Promo text overlay
                  // Positioned(
                  //   bottom: 0,
                  //   left: 0,
                  //   right: 0,
                  //   child: Container(
                  //     padding: const EdgeInsets.all(16),
                  //     decoration: BoxDecoration(
                  //       gradient: LinearGradient(
                  //         begin: Alignment.topCenter,
                  //         end: Alignment.bottomCenter,
                  //         colors: [
                  //           Colors.transparent,
                  //           Colors.black.withOpacity(0.7),
                  //         ],
                  //       ),
                  //     ),
                  //     child: Text(
                  //       post.caption ?? 'Promo Video/Photos',
                  //       style: const TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
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

        const SizedBox(height: 12),

        // Action Buttons (Like, Comment, Save)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey[600],
                  size: 24,
                ),
                onPressed: handlePostLike,
              ),
              const SizedBox(width: 4),
              Text(
                likesCount.toString(),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? Colors.blue : Colors.grey[600],
                  size: 24,
                ),
                onPressed: handlePostSave,
              ),
              const SizedBox(width: 4),
              Text(
                savesCount.toString(),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
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
