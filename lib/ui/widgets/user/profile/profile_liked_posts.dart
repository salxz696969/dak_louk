import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/widgets/user/profile/profile_post_item.dart';
import 'package:flutter/material.dart';

class LikedPosts extends StatelessWidget {
  final List<UserProfileLikedSavedPostsVM> likedPosts;
  const LikedPosts({super.key, required this.likedPosts});

  @override
  Widget build(BuildContext context) {
    if (likedPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No liked posts found.')),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: likedPosts.length,
      itemBuilder: (context, index) {
        final post = likedPosts[index];
        return ProfilePostItem(post: post);
      },
    );
  }
}
