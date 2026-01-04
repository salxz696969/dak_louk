import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant/post_service.dart';
import 'package:dak_louk/ui/widgets/merchant/posts/post_form.dart';
import 'package:dak_louk/ui/widgets/user/posts/post_item.dart';
import 'package:flutter/material.dart';

class MerchantPostsScreen extends StatefulWidget {
  const MerchantPostsScreen({super.key});

  @override
  State<MerchantPostsScreen> createState() => _MerchantPostsScreenState();
}

class _MerchantPostsScreenState extends State<MerchantPostsScreen> {
  final PostService _postService = PostService();

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
        child: PostForm(
          post: post,
          onSaved: (savedPost) {
            // setState(() {
            //   if (post == null) {
            //     // Add new post
            //     _posts.insert(0, savedPost);
            //   } else {
            //     // Update existing post
            //     final index = _posts.indexWhere(
            //       (p) => p.id == savedPost.id,
            //     );
            //     if (index != -1) {
            //       _posts[index] = savedPost;
            //     }
            //   }
            // });
          },
        ),
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
                  return PostItem(post: post);
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
