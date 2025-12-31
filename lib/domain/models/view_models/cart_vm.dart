part of domain;

class CartVM extends Cacheable {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related primitive data
  final String? productName;
  final double? productPrice;
  final String? productImageUrl;
  final String? merchantName;
  final int? productQuantityAvailable;

  CartVM({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.productName,
    this.productPrice,
    this.productImageUrl,
    this.merchantName,
    this.productQuantityAvailable,
  });

  factory CartVM.fromRaw(
    CartModel raw, {
    String? productName,
    double? productPrice,
    String? productImageUrl,
    String? merchantName,
    int? productQuantityAvailable,
  }) {
    return CartVM(
      id: raw.id,
      userId: raw.userId,
      productId: raw.productId,
      quantity: raw.quantity,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      productName: productName,
      productPrice: productPrice,
      productImageUrl: productImageUrl,
      merchantName: merchantName,
      productQuantityAvailable: productQuantityAvailable,
    );
  }

  // Simple getters
  double get totalPrice => (productPrice ?? 0.0) * quantity;
}
