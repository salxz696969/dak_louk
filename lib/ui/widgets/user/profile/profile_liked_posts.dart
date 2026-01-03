import 'package:dak_louk/domain/models/models.dart';
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
        return PhotoContainer(post: post);
      },
    );
  }
}

class PhotoContainer extends StatelessWidget {
  final UserProfileLikedSavedPostsVM post;

  const PhotoContainer({required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ProductInfoScreen(post: post),
      //     ),
      //   );
      // },
      child: Stack(
        children: [
          Positioned.fill(
            child: Image(image: AssetImage(post.imageUrl), fit: BoxFit.cover),
          ),
          if (post.imageUrl.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.collections,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
