import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/widgets/screens/profile/profile_liked_posts.dart';
import 'package:flutter/material.dart';

class SavedPosts extends StatelessWidget {
  // replace this with your service/provider as needed
  final List<UserProfileLikedSavedPostsVM> savedPosts;
  const SavedPosts({super.key, required this.savedPosts});

  @override
  Widget build(BuildContext context) {
    if (savedPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No saved posts found.')),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: savedPosts.length,
      itemBuilder: (context, index) {
        final post = savedPosts[index];
        return PhotoContainer(post: post);
      },
    );
  }
}
