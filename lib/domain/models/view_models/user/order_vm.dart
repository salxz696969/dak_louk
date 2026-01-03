part of models;

class OrderVM extends Cacheable {
  final int id;
  final String username;
  final String userProfileImage;
  final String merchantName;
  final String merchantProfileImage;
  final String status;
  final List<OrderProductVM> products;
  final int totalPrice;

  final DateTime createdAt;

  OrderVM({
    required this.id,
    required this.username,
    required this.userProfileImage,
    required this.merchantName,
    required this.merchantProfileImage,
    required this.status,
    required this.products,
    required this.totalPrice,
    required this.createdAt,
  });

  factory OrderVM.fromRaw(
    OrderModel raw, {
    required String username,
    required String userProfileImage,
    required String merchantName,
    required String merchantProfileImage,
    required List<OrderProductVM> products,
    required int totalPrice,
  }) {
    return OrderVM(
      id: raw.id,
      username: username,
      userProfileImage: userProfileImage,
      merchantName: merchantName,
      merchantProfileImage: merchantProfileImage,
      status: raw.status,
      products: products,
      totalPrice: totalPrice,
      createdAt: raw.createdAt,
    );
  }
}

class OrderProductVM extends Cacheable {
  final int id;
  final String productName;
  final String productImageUrl;
  final int quantity;

  OrderProductVM({
    required this.id,
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
  });

  factory OrderProductVM.fromRaw(
    OrderProductModel raw, {
    required String productName,
    required String productImageUrl,
  }) {
    return OrderProductVM(
      id: raw.id,
      productName: productName,
      productImageUrl: productImageUrl,
      quantity: raw.quantity,
    );
  }
}
