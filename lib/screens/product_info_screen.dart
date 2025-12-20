import 'package:dak_louk/widgets/add_and_remove_button.dart';
import 'package:dak_louk/widgets/appbar.dart';
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
  final String quantity;
  const ProductInfoScreen({
    super.key,
    required this.description,
    required this.quantity,
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Appbar(title: widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 12.0,
              ),
              child: UsernameContainer(
                rating: widget.rating,
                profile: widget.profile,
                username: widget.username,
              ),
            ),
            PhotoSlider(
              quantity: widget.quantity,
              images: widget.images,
              page: _page,
              controller: controller,
              onChanged: _onChanged,
            ),
            const SizedBox(height: 30),
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                widget.date,
                style: const TextStyle(fontSize: 14, color: Color(0xFF777777)),
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
            _SimilarItem(
              images: widget.images,
              titles: ['Similar Item 1', 'Similar Item 2', 'Similar Item 3'],
              prices: ['19.99', '29.99', '39.99'],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SimilarItem extends StatefulWidget {
  final List<ImageProvider> images;
  final List<String> titles;
  final List<String> prices;
  const _SimilarItem({
    required this.images,
    required this.titles,
    required this.prices,
  });

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
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: SizedBox(
        height: 300,
        child: PageView.builder(
          padEnds: false,
          controller: controller,
          itemCount: 10,
          itemBuilder: (context, index) {
            final qty = _quantities[index];
            final isAdded = qty > 0;
            return Padding(
              padding: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Image(
                        image: widget.images[index % widget.images.length],
                        fit: BoxFit.cover,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        border: Border(
                          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.titles[index % widget.titles.length],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "\$${widget.prices[index % widget.prices.length]}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[100],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          isAdded
                              ? const AddAndRemoveButton(reverseColor: true)
                              : InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () =>
                                      setState(() => _quantities[index] = 1),
                                  child: Icon(
                                    CupertinoIcons.add_circled_solid,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
