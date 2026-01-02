import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant_service.dart';
import 'package:flutter/material.dart';

class MerchantPosts extends StatelessWidget {
  final MerchantService _merchantService = MerchantService();
  final int merchantId;
  MerchantPosts({required this.merchantId});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MerchantPostsVM>>(
      future: _merchantService.getMerchantPosts(merchantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No posts found.')),
          );
        }
        final posts = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (context, index) {
            final post = posts[index];
            return _PhotoContainer(post: post);
          },
          itemCount: posts.length,
        );
      },
    );
  }
}

class _PhotoContainer extends StatelessWidget {
  final MerchantPostsVM post;

  const _PhotoContainer({required this.post});

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
