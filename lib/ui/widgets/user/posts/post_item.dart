import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/user/post_like_service.dart';
import 'package:dak_louk/domain/services/user/post_save_service.dart';
import 'package:dak_louk/ui/widgets/merchant/posts/post_create_form.dart';
import 'package:dak_louk/ui/widgets/user/posts/product_item.dart';
import 'package:dak_louk/ui/screens/user/merchant_profile_screen.dart';
import 'package:dak_louk/ui/screens/user/post_detail_screen.dart';
import 'package:flutter/material.dart';

class PostItem extends StatefulWidget {
  final PostVM post;
  final VoidCallback? onPostDeleted;
  final void Function(PostVM updatedPost)? onPostUpdated;

  const PostItem({
    super.key,
    required this.post,
    this.onPostDeleted,
    this.onPostUpdated,
  });

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

  void _showPostForm() {
    showModalBottomSheet(
      enableDrag: true,
      isDismissible: true,
      showDragHandle: true,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PostForm(
          post: widget.post,
          onSaved: (updatedPost) {
            widget.onPostUpdated?.call(updatedPost);
          },
        ),
      ),
    );
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      widget.onPostDeleted?.call();
    }
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: widget.post.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only the merchant header's InkWell should NOT open the post detail
    // Rest of the item should navigate to post detail
    return GestureDetector(
      onTap: _navigateToDetail,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Merchant Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MerchantProfileScreen(
                          merchant: MerchantVM(
                            id: widget.post.merchant.id,
                            username: widget.post.merchant.username,
                            rating: widget.post.merchant.rating,
                            bio: widget.post.merchant.bio,
                            profileImage: widget.post.merchant.profileImage,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(
                          widget.post.merchant.profileImage,
                        ),
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.merchant.username,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.post.merchant.rating.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showPostForm();
                    } else if (value == 'delete') {
                      _deletePost();
                    }
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
                  onPressed: () {
                    // Prevent the parent GestureDetector from firing
                    handlePostLike();
                  },
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
                  onPressed: () {
                    // Prevent the parent GestureDetector from firing
                    handlePostSave();
                  },
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
      ),
    );
  }
}
