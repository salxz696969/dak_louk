import 'package:dak_louk/widgets/add_and_remove_button.dart';
import 'package:dak_louk/widgets/photo_slider.dart';
import 'package:dak_louk/widgets/usernameContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductInfoScreen extends StatefulWidget {
  final String description;
  final List<ImageProvider> images;
  final ImageProvider profile;
  final String username;
  final String price;
  final String title;
  final String date;
  final String rating;
  const ProductInfoScreen({
    super.key,
    required this.description,
    required this.images,
    required this.profile,
    required this.username,
    required this.price,
    required this.title,
    required this.date,
    required this.rating,
  });

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  late final PageController controller;
  int _page = 0;
  int quantity = 1;
  void onAdd() {
    setState(() {
      quantity = quantity + 1;
    });
  }

  void onRemove() {
    setState(() {
      if (quantity > 0) quantity--;
    });
  }

  void _onChanged(int i) {
    setState(() {
      _page = i;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UsernameContainer(
                  profile: widget.profile,
                  username: widget.username,
                ),
                Text(
                  widget.date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
          PhotoSlider(
            images: widget.images,
            page: _page,
            rating: widget.rating,
            controller: controller,
            onChanged: _onChanged,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "\$${widget.price}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              widget.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AddAndRemoveButton(),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: const Text(
              "Similar Items",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ),
          _SimilarItem(images: widget.images),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SimilarItem extends StatefulWidget {
  final List<ImageProvider> images;
  const _SimilarItem({required this.images});

  @override
  State<_SimilarItem> createState() => _SimilarItemState();
}

class _SimilarItemState extends State<_SimilarItem> {
  late PageController controller;
  late List<int> _quantities;

  @override
  void initState() {
    super.initState();
    controller = PageController(viewportFraction: 0.8);
    _quantities = List<int>.filled(10, 0);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: controller,
        itemCount: 10,
        itemBuilder: (context, index) {
          final qty = _quantities[index];
          final isAdded = qty > 0;
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image(
                        image: widget.images[index % widget.images.length],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: isAdded
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: AddAndRemoveButton(),
                            )
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _quantities[index] = 1),
                                child: Icon(
                                  CupertinoIcons.add_circled_solid,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  size: 30,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
