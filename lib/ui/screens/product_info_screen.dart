import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/services/post_service.dart';
import 'package:dak_louk/ui/widgets/add_and_remove_button.dart';
import 'package:dak_louk/ui/widgets/appbar.dart';
import 'package:dak_louk/ui/widgets/photo_slider.dart';
import 'package:dak_louk/ui/widgets/post_slider.dart';
import 'package:dak_louk/ui/widgets/username_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductInfoScreen extends StatefulWidget {
  final PostModel post;
  const ProductInfoScreen({super.key, required this.post});

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  int quantity = 1;
  void onAdd() {
    setState(() {
      quantity = quantity + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ui = widget.post.ui();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Appbar(title: 'Product Information'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                top: 8.0,
                bottom: 2.0,
              ),
              child: UsernameContainer(
                userId: ui.userId,
                rating: ui.rating,
                bio: ui.bio,
                profile: AssetImage(ui.profileImage),
                username: ui.username,
              ),
            ),
            PhotoSlider(
              quantity: ui.quantity,
              images: ui.images.map((image) => AssetImage(image)).toList(),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                ui.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "\$${ui.price}",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                ui.date,
                style: const TextStyle(fontSize: 13, color: Color(0xFF777777)),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                ui.description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: AddAndRemoveButton(
                baseQuantity: 1,
                size: 30.0,
                cart: CartModel(
                  id: 0,
                  userId: 1,
                  productId: ui.productId,
                  quantity: quantity,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: const Text(
                "Similar Items",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
            _SimilarItems(category: ui.category ?? ''),
          ],
        ),
      ),
    );
  }
}

class _SimilarItems extends StatelessWidget {
  final String category;
  final PostService _postService = PostService();
  _SimilarItems({required this.category});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostModel>>(
      future: _postService.getAllPosts(category, 10),
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
