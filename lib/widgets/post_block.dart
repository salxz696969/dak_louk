import 'package:dak_louk/models/post_model.dart';
import 'package:dak_louk/screens/product_info_screen.dart';
import 'package:dak_louk/widgets/add_and_remove_button.dart';
import 'package:dak_louk/widgets/photo_slider.dart';
import 'package:dak_louk/widgets/usernameContainer.dart';
import 'package:flutter/material.dart';

class PostBlock extends StatefulWidget {
  final Post post;

  const PostBlock({super.key, required this.post});

  @override
  State<PostBlock> createState() => _PostBlockState();
}

class _PostBlockState extends State<PostBlock> {
  late final PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) => setState(() => _page = i);

  @override
  Widget build(BuildContext context) {
    final user = widget.post.user;
    final product = widget.post.product;
    final images = widget.post.images ?? [];

    final profileImage = (user?.profileImageUrl != null)
        ? AssetImage(user!.profileImageUrl)
        : const AssetImage('assets/profiles/profile1.png');

    final username = user?.username ?? 'Unknown';
    final rating = user?.rating.toStringAsFixed(2) ?? '0.00';

    final quantity = product?.quantity.toString() ?? '1';
    final price = product?.price.toStringAsFixed(2) ?? '0.0';
    final description = product?.description ?? '';
    final title = widget.post.title;

    final date = timeAgo(widget.post.createdAt);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UsernameContainer(
          profile: profileImage,
          username: username,
          rating: rating,
        ),
        if (images.isNotEmpty)
          PhotoSlider(
            quantity: images.length.toString(),
            images: images.map((url) => AssetImage(url)).toList(),
            page: _page,
            controller: _pageController,
            onChanged: _onPageChanged,
          ),
        if (images.isNotEmpty) const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        ),
        _ActionsAndMeta(
          quantity: quantity,
          images: images.map((url) => AssetImage(url)).toList(),
          profile: profileImage,
          username: username,
          rating: rating,
          title: title,
          date: date,
          price: price,
          description: description,
        ),
      ],
    );
  }
}

class _ActionsAndMeta extends StatelessWidget {
  final String title;
  final String date;
  final String price;
  final String rating;
  final List<ImageProvider> images;
  final ImageProvider profile;
  final String username;
  final String description;
  final String quantity;

  const _ActionsAndMeta({
    required this.images,
    required this.quantity,
    required this.description,
    required this.profile,
    required this.username,
    required this.rating,
    required this.title,
    required this.date,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$$price",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              _AddToCartButton(),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductInfoScreen(
                        quantity: quantity,
                        description: description,
                        images: images,
                        profile: profile,
                        username: username,
                        price: price,
                        title: title,
                        date: date,
                        rating: rating,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "View more",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 96, 96, 96),
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                date,
                style: const TextStyle(fontSize: 14, color: Color(0xFF777777)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddToCartButton extends StatefulWidget {
  const _AddToCartButton();

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  bool isAdded = false;
  void onAdd() {
    setState(() {
      isAdded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdded) {
      return InkWell(
        onTap: onAdd,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: Theme.of(context).colorScheme.secondary,
            border: Border.all(
              width: 1.5,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(6.0),
            child: Text(
              "Add to Cart",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      );
    }

    return AddAndRemoveButton();
  }
}

String timeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}s ago';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '${weeks}w ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '${months}mo ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '${years}y ago';
  }
}
