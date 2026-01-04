part of models;

class OrderMerchantVM extends Cacheable {
  final int id;
  final String username;
  final String userProfileImage;
  final OrderStatusEnum status;
  final List<OrderProductMerchantVM> products;
  final int totalPrice;

  final DateTime createdAt;

  OrderMerchantVM({
    required this.id,
    required this.username,
    required this.userProfileImage,
    required this.status,
    required this.products,
    required this.totalPrice,
    required this.createdAt,
  });

  factory OrderMerchantVM.fromRaw(
    OrderModel raw, {
    required String username,
    required String userProfileImage,
    required List<OrderProductMerchantVM> products,
    required int totalPrice,
  }) {
    return OrderMerchantVM(
      id: raw.id,
      username: username,
      userProfileImage: userProfileImage,
      status: OrderStatusEnum.values.firstWhere((e) => e.name == raw.status),
      products: products,
      totalPrice: totalPrice,
      createdAt: raw.createdAt,
    );
  }
}

class OrderProductMerchantVM extends Cacheable {
  final int id;
  final String productName;
  final String productImageUrl;
  final int quantity;

  OrderProductMerchantVM({
    required this.id,
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
  });

  factory OrderProductMerchantVM.fromRaw(
    OrderProductModel raw, {
    required String productName,
    required String productImageUrl,
  }) {
    return OrderProductMerchantVM(
      id: raw.id,
      productName: productName,
      productImageUrl: productImageUrl,
      quantity: raw.quantity,
    );
  }
}
