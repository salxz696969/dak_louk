part of domain;

class CartModel {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final String updatedAt;
  final String createdAt;

  final UserModel? user;
  final ProductModel? product;
  final UserModel? seller;

  CartModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.seller,
    this.product,
  });

  CartUI ui() {
    return CartUI(
      title: product?.title ?? 'Unknown',
      price: product != null ? '\$${product!.price.toStringAsFixed(2)}' : 'N/A',
      quantity: quantity,
      image: [product?.image ?? 'assets/images/coffee1.png'],
      sellerName: seller?.username ?? 'Unknown',
      sellerRating: double.parse((seller?.rating ?? 0.0).toStringAsFixed(2)),
    );
  }
}

class CartUI {
  final String title;
  final String price;
  final int quantity;
  final List<String> image;
  final String sellerName;
  final double sellerRating;

  CartUI({
    required this.title,
    required this.price,
    required this.quantity,
    required this.image,
    required this.sellerName,
    required this.sellerRating,
  });
}
