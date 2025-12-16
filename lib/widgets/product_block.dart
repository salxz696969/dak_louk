import 'package:dak_louk/screens/chat_screen.dart';
import 'package:dak_louk/screens/product_info_screen.dart';
import 'package:dak_louk/widgets/add_and_remove_button.dart';
import 'package:dak_louk/widgets/base_scaffold.dart';
import 'package:dak_louk/widgets/photo_slider.dart';
import 'package:dak_louk/widgets/usernameContainer.dart';
import 'package:flutter/material.dart';

class ProductBlock extends StatefulWidget {
  final String title;
  final List<ImageProvider> images;
  final ImageProvider profile;
  final String username;
  final String description;
  final String price;
  final String rating;
  final String date;

  const ProductBlock({
    super.key,
    required this.date,
    required this.title,
    required this.rating,
    required this.images,
    required this.profile,
    required this.username,
    required this.description,
    required this.price,
  });

  @override
  State<ProductBlock> createState() => _ProductBlockState();
}

class _ProductBlockState extends State<ProductBlock> {
  late final PageController _pageController;
  int _page = 0;

  List<ImageProvider> get _images => widget.images;

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          profile: widget.profile,
          username: widget.username,
          onViewDetails: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BaseScaffold(
                  body: ProductInfoScreen(
                    description: widget.description,
                    images: widget.images,
                    profile: widget.profile,
                    username: widget.username,
                    price: widget.price,
                    title: widget.title,
                    date: widget.date,
                    rating: widget.rating,
                  ),
                ),
              ),
            );
          },
        ),
        if (_images.isNotEmpty)
          PhotoSlider(
            rating: widget.rating,
            images: _images,
            page: _page,
            controller: _pageController,
            onChanged: _onPageChanged,
          ),
        if (_images.isNotEmpty) const SizedBox(height: 8.0),
        _ActionsAndMeta(
          title: widget.title,
          date: widget.date,
          price: widget.price,
          onChat: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BaseScaffold(body: ChatScreen()),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final ImageProvider? profile;
  final String? username;
  final VoidCallback onViewDetails;

  const _Header({
    required this.profile,
    required this.username,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UsernameContainer(profile: profile!, username: username!),
          InkWell(
            onTap: onViewDetails,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.grey, width: 1.5),
              ),
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Text("View Details"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsAndMeta extends StatelessWidget {
  final String title;
  final String date;
  final VoidCallback onChat;
  final String price;

  const _ActionsAndMeta({
    required this.title,
    required this.date,
    required this.onChat,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
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
            Row(
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ],
        ),
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
