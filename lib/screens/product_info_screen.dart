import 'package:dak_louk/db/dao/post_dao.dart';
import 'package:dak_louk/models/post_model.dart';
import 'package:dak_louk/widgets/add_and_remove_button.dart';
import 'package:dak_louk/widgets/appbar.dart';
import 'package:dak_louk/widgets/photo_slider.dart';
import 'package:dak_louk/widgets/username_container.dart';
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
  final String category;
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
    required this.category,
  });

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
                rating: widget.rating,
                profile: widget.profile,
                username: widget.username,
              ),
            ),
            PhotoSlider(
              quantity: widget.quantity,
              images: widget.images,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "\$${widget.price}",
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
                widget.date,
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
                widget.description,
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
              child: AddAndRemoveButton(quantity: quantity, size: 30.0),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: const Text(
                "Similar Items",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
            _SimilarItems(category: widget.category),
          ],
        ),
      ),
    );
  }
}

class _SimilarItems extends StatefulWidget {
  final String category;

  const _SimilarItems({required this.category});

  @override
  State<_SimilarItems> createState() => _SimilarItemsState();
}

class _SimilarItemsState extends State<_SimilarItems> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: FutureBuilder<List<Post>>(
        future: PostDao().getAllPosts(widget.category, 10),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts found.'));
          }

          final posts = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: PageView.builder(
              controller: _controller,
              padEnds: false,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final ui = post.ui();

                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: _SimilarItemCard(
                    image: ui['images'],
                    title: ui['title'],
                    price: ui['price'],
                    rating: ui['rating'],
                    profile: ui['profileImage'],
                    username: ui['username'],
                    quantity: ui['quantity'],
                    date: ui['date'],
                    description: ui['description'],
                    category: ui['category'],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SimilarItemCard extends StatefulWidget {
  final List<ImageProvider> image;
  final String title;
  final String price;
  final String rating;
  final ImageProvider profile;
  final String username;
  final String quantity;
  final String date;
  final String description;
  final String category;

  const _SimilarItemCard({
    required this.image,
    required this.title,
    required this.price,
    required this.rating,
    required this.profile,
    required this.username,
    required this.quantity,
    required this.date,
    required this.description,
    required this.category,
  });

  @override
  State<_SimilarItemCard> createState() => _SimilarItemCardState();
}

class _SimilarItemCardState extends State<_SimilarItemCard> {
  bool isAdded = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductInfoScreen(
              description: widget.description,
              quantity: widget.quantity,
              images: widget.image,
              profile: widget.profile,
              username: widget.username,
              price: widget.price,
              title: widget.title,
              date: widget.date,
              rating: widget.rating,
              category: widget.category,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image(image: widget.image[0], fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(190, 0, 0, 0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          '${widget.quantity} left',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 18, backgroundImage: widget.profile),
                      const SizedBox(width: 6),
                      Column(
                        children: [
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Text(
                                widget.rating,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[200],
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "\$${widget.price}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 25,
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
                                child: AddAndRemoveButton(
                                  quantity: int.parse(widget.quantity),
                                  size: 25.0,
                                ),
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
                                  onTap: () {
                                    setState(() {
                                      isAdded = true;
                                    });
                                  },
                                  child: Icon(
                                    CupertinoIcons.add_circled_solid,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    size: 25.0,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
