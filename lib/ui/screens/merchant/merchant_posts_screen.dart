import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant/post_service.dart';
import 'package:dak_louk/ui/widgets/merchant/posts/post_create_form.dart';
import 'package:dak_louk/ui/widgets/merchant/posts/post_edit_form.dart';
import 'package:dak_louk/ui/widgets/merchant/posts/post_item.dart';
import 'package:flutter/material.dart';

class MerchantPostsScreen extends StatefulWidget {
  const MerchantPostsScreen({super.key});

  @override
  State<MerchantPostsScreen> createState() => _MerchantPostsScreenState();
}

class _MerchantPostsScreenState extends State<MerchantPostsScreen> {
  final PostService _postService = PostService();

  void _showEditPost(PostVM post) {
    _showPostForm(context, post: post);
  }

  Future<void> _deletePost(PostVM post) async {
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
      try {
        await _postService.deletePost(post.id);
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      }
    }
  }

  void _showPostForm(BuildContext context, {PostVM? post}) {
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
        child: post == null
            ? PostForm(onSaved: (_) => setState(() {}))
            : PostEditForm(post: post, onSaved: (_) => setState(() {})),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostVM>>(
      future: _postService.getAllPostsForCurrentMerchant(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts found.'));
        } else {
          final posts = snapshot.data!;
          return Stack(
            children: [
              ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostItem(
                    post: post,
                    onEdit: () => _showEditPost(post),
                    onDelete: () => _deletePost(post),
                  );
                },
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () => _showPostForm(context),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
