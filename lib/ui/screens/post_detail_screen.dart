import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/post_service.dart';
import 'package:dak_louk/ui/widgets/common/appbar.dart';
import 'package:dak_louk/ui/widgets/screens/user/posts/post_item.dart';
import 'package:dak_louk/ui/widgets/screens/user/posts/post_slider.dart';
import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Appbar(title: 'Post Detail'),
      ),
      body: FutureBuilder<PostVM?>(
        future: _postService.getPostById(widget.postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Post not found.'));
          } else {
            final post = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  PostItem(post: post),
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(10),
                    child: Text(
                      "Similar Posts",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _SimilarItems(postId: post.id),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class _SimilarItems extends StatelessWidget {
  final int postId;
  final PostService _postService = PostService();
  _SimilarItems({required this.postId});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostVM>>(
      future: _postService.getSimilarPosts(postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No similar items found.'));
        } else {
          final posts = snapshot.data!;
          return PostSlider(posts: posts);
        }
      },
    );
  }
}
