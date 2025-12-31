part of domain;

class CartVM extends Cacheable {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final UserVM? user;
  final ProductVM? product;

  // UI-specific computed properties
  final String displayProductName;
  final String displayPrice;
  final String displayTotalPrice;
  final String displayQuantity;
  final String displayMerchantName;
  final String displayMerchantRating;
  final String displayProductImage;

  CartVM({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.product,
  }) : displayProductName = product?.name ?? 'Unknown Product',
       displayPrice = product?.displayPrice ?? '\$0.00',
       displayTotalPrice = _calculateTotalPrice(
         product?.price ?? 0.0,
         quantity,
       ),
       displayQuantity = quantity.toString(),
       displayMerchantName = product?.merchant?.username ?? 'Unknown Merchant',
       displayMerchantRating = product?.merchant?.displayRating ?? '0.00',
       displayProductImage =
           product?.primaryImage ?? 'assets/images/coffee1.png';

  factory CartVM.fromRaw(CartModel raw, {UserVM? user, ProductVM? product}) {
    return CartVM(
      id: raw.id,
      userId: raw.userId,
      productId: raw.productId,
      quantity: raw.quantity,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      user: user,
      product: product,
    );
  }

  static String _calculateTotalPrice(double unitPrice, int quantity) {
    final total = unitPrice * quantity;
    return '\$${total.toStringAsFixed(2)}';
  }

  double get totalPrice => (product?.price ?? 0.0) * quantity;

  bool get isAvailable => product?.isInStock ?? false;

  String get availabilityStatus => isAvailable ? 'Available' : 'Out of Stock';
}
