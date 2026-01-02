import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/post_service.dart';
import 'package:dak_louk/ui/widgets/add_and_remove_button.dart';
import 'package:dak_louk/ui/widgets/appbar.dart';
import 'package:dak_louk/ui/widgets/posts/product_photo_slider.dart';
import 'package:dak_louk/ui/widgets/posts/post_slider.dart';
import 'package:dak_louk/ui/widgets/posts/username_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductInfoScreen extends StatefulWidget {
  final PostVM post;
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
                merchantId: widget.post.merchantId,
                rating: "0.0", // to change
                bio: "", // to change
                profile: AssetImage(widget.post.merchant.profileImage),
                username: widget.post.merchant.username,
              ),
            ),
            PhotoSlider(
              quantity: 0, // to change
              images:
                  widget.post.promoMedias
                      ?.map((promoMedia) => AssetImage(promoMedia.url))
                      .toList() ??
                  [],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.post.caption ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "\$${widget.post.products.first.price}", // to change
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
                widget.post.createdAt.toLocal().toString(),
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
                widget.post.caption ?? '',
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
                cart: CartVM(
                  merchant: CartMerchantVM(
                    id: widget.post.merchantId,
                    username: widget.post.merchant.username,
                    profileImage: widget.post.merchant.profileImage,
                  ),
                  items: [
                    CartItemVM(
                      id: widget.post.products.first.id,
                      name: widget.post.products.first.name,
                      price: widget.post.products.first.price,
                      image: widget.post.products.first.imageUrls.first,
                      userId: widget.post.merchantId,
                      productId: widget.post.products.first.id,
                      quantity: 1,
                      availableQuantity: widget.post.products.first.quantity,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  ],
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
            _SimilarItems(
              category: widget.post.products.first.category.name,
            ), // to change
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
    return FutureBuilder<List<PostVM>>(
      future: _postService.getAllPosts(
        category: ProductCategory.values.firstWhere(
          (e) => e.name == category,
          orElse: () => ProductCategory.others,
        ),
        limit: 10,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No similar items found.'));
        } else {
          final posts = snapshot.data!;
          return PostSlider(posts: List<PostVM>.empty()); // to change
        }
      },
    );
  }
}
