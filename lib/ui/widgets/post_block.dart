import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/cart_service.dart';
import 'package:dak_louk/ui/widgets/add_and_remove_button.dart';
import 'package:dak_louk/ui/screens/product_info_screen.dart';
import 'package:dak_louk/ui/widgets/photo_slider.dart';
import 'package:dak_louk/ui/widgets/username_container.dart';
import 'package:flutter/material.dart';

class PostBlock extends StatefulWidget {
  final PostVM post;

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
          bio: widget.post.merchantName ?? '',
          merchantId: widget.post.merchantId,
          profile: AssetImage(widget.post.merchantProfileImage ?? ''),
          username: widget.post.merchantName ?? '',
          rating: widget.post.merchantName ?? '', // to change
        ),
        PhotoSlider(
          quantity: "",
          images:
              widget.post.mediaUrls
                  ?.map((image) => AssetImage(image))
                  .toList() ??
              [],
        ),
        if (widget.post.mediaUrls?.isNotEmpty ?? false)
          const SizedBox(height: 8.0),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0)),
        _ActionsAndMeta(post: widget.post),
      ],
    );
  }
}

class _ActionsAndMeta extends StatelessWidget {
  final PostVM post;
  const _ActionsAndMeta({required this.post});

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
                "\$${post.productNames?.first ?? '0'}", // to change
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              _AddToCartButton(
                cart: CartVM(
                  id: 0,
                  userId: post.merchantId,
                  productId: post.id,
                  quantity: 1,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            post.caption ?? '',
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
                      builder: (_) => ProductInfoScreen(post: post),
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
                post.createdAt.toLocal().toString(),
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
  final CartVM cart;
  const _AddToCartButton({required this.cart});

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  late int cartId;
  late bool isAdded;
  CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    isAdded = false;
    cartId = 0;
  }

  void onAdd() async {
    final cart = await _cartService.createCart(
      CreateCartDTO(productId: widget.cart.productId, quantity: 1),
    );
    setState(() {
      cartId = cart!.id;
    });
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

    return AddAndRemoveButton(
      baseQuantity: 1,
      cart: CartVM(
        id: cartId,
        userId: widget.cart.userId,
        productId: widget.cart.productId,
        quantity: widget.cart.quantity,
        createdAt: widget.cart.createdAt,
        updatedAt: widget.cart.updatedAt,
      ),
    );
  }
}
