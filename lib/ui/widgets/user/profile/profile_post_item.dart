import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/screens/user/post_detail_screen.dart';
import 'package:flutter/material.dart';

class ProfilePostItem extends StatelessWidget {
  final UserProfileLikedSavedPostsVM post;

  const ProfilePostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postId: post.id),
          ),
        );
      },
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
