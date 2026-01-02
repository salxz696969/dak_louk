part of domain;

class OrderVM extends Cacheable {
  final int id;
  final int userId;
  final int merchantId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related primitive data
  final String? userName;
  final String? merchantName;
  final double totalAmount;
  final int totalItems;
  final List<String>? productNames;

  OrderVM({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.merchantName,
    this.totalAmount = 0.0,
    this.totalItems = 0,
    this.productNames,
  });

  factory OrderVM.fromRaw(
    OrderModel raw, {
    String? userName,
    String? merchantName,
    double totalAmount = 0.0,
    int totalItems = 0,
    List<String>? productNames,
  }) {
    return OrderVM(
      id: raw.id,
      userId: raw.userId,
      merchantId: raw.merchantId,
      status: raw.status,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      userName: userName,
      merchantName: merchantName,
      totalAmount: totalAmount,
      totalItems: totalItems,
      productNames: productNames,
    );
  }
}

class OrderProductVM extends Cacheable {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;

  // Related primitive data
  final String? productName;
  final String? productImageUrl;

  OrderProductVM({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    this.productName,
    this.productImageUrl,
  });

  factory OrderProductVM.fromRaw(
    OrderProductModel raw, {
    String? productName,
    String? productImageUrl,
  }) {
    return OrderProductVM(
      id: raw.id,
      orderId: raw.orderId,
      productId: raw.productId,
      quantity: raw.quantity,
      productName: productName,
      productImageUrl: productImageUrl,
    );
  }
}
