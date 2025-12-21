import 'package:dak_louk/models/post_model.dart';
import 'package:dak_louk/screens/product_info_screen.dart';
import 'package:dak_louk/widgets/add_and_remove_button.dart';
import 'package:dak_louk/widgets/photo_slider.dart';
import 'package:dak_louk/widgets/username_container.dart';
import 'package:flutter/material.dart';

class PostBlock extends StatefulWidget {
  final Post post;

  const PostBlock({super.key, required this.post});

  @override
  State<PostBlock> createState() => _PostBlockState();
}

class _PostBlockState extends State<PostBlock> {
  late final PageController _pageController;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UsernameContainer(
          profile: widget.post.ui()['profileImage'],
          username: widget.post.ui()['username'],
          rating: widget.post.ui()['rating'],
        ),
        if (widget.post.ui().isNotEmpty)
          PhotoSlider(
            quantity: widget.post.ui()['quantity'],
            images: widget.post.ui()['images'],
          ),
        if ((widget.post.ui()['images'] as List).isNotEmpty)
          const SizedBox(height: 8.0),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0)),
        _ActionsAndMeta(
          quantity: widget.post.ui()['quantity'],
          images: widget.post.ui()['images'],
          profile: widget.post.ui()['profileImage'],
          username: widget.post.ui()['username'],
          rating: widget.post.ui()['rating'],
          title: widget.post.ui()['title'],
          date: widget.post.ui()['date'],
          price: widget.post.ui()['price'],
          description: widget.post.ui()['description'],
          category: widget.post.ui()['category'],
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
  final String category;

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
    required this.category,
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
              _AddToCartButton(quantity: int.parse(quantity)),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5.0),
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
                        category: category,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "View more",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 96, 96, 96),
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddToCartButton extends StatefulWidget {
  final int quantity;
  const _AddToCartButton({required this.quantity});

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

    return AddAndRemoveButton(quantity: widget.quantity);
  }
}
