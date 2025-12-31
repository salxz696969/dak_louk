part of domain;

class OrderVM extends Cacheable {
  final int id;
  final int userId;
  final int merchantId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final UserVM? user;
  final UserVM? merchant;
  final List<OrderProductVM>? products;

  // UI-specific computed properties
  final String displayStatus;
  final String displayDate;
  final String displayTotalAmount;
  final String statusColor;
  final bool canCancel;
  final bool canComplete;

  OrderVM({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.merchant,
    this.products,
  })  : displayStatus = _formatStatus(status),
        displayDate = _formatDate(createdAt),
        displayTotalAmount = _calculateTotal(products),
        statusColor = _getStatusColor(status),
        canCancel = status == 'waiting' || status == 'accepted',
        canComplete = status == 'delivering';

  factory OrderVM.fromRaw(
    OrderModel raw, {
    UserVM? user,
    UserVM? merchant,
    List<OrderProductVM>? products,
  }) {
    return OrderVM(
      id: raw.id,
      userId: raw.userId,
      merchantId: raw.merchantId,
      status: raw.status,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      user: user,
      merchant: merchant,
      products: products,
    );
  }

  static String _formatStatus(String status) {
    switch (status) {
      case 'waiting':
        return 'Waiting for Confirmation';
      case 'accepted':
        return 'Accepted';
      case 'delivering':
        return 'Out for Delivery';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _calculateTotal(List<OrderProductVM>? products) {
    if (products == null || products.isEmpty) return '\$0.00';
    
    final total = products.fold<double>(
      0.0,
      (sum, product) => sum + product.totalPrice,
    );
    
    return '\$${total.toStringAsFixed(2)}';
  }

  static String _getStatusColor(String status) {
    switch (status) {
      case 'waiting':
        return 'orange';
      case 'accepted':
        return 'blue';
      case 'delivering':
        return 'purple';
      case 'completed':
        return 'green';
      case 'cancelled':
        return 'red';
      default:
        return 'gray';
    }
  }

  double get totalAmount {
    if (products == null || products!.isEmpty) return 0.0;
    return products!.fold<double>(0.0, (sum, product) => sum + product.totalPrice);
  }

  int get totalItems {
    if (products == null || products!.isEmpty) return 0;
    return products!.fold<int>(0, (sum, product) => sum + product.quantity);
  }
}

class OrderProductVM extends Cacheable {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double priceSnapshot;

  // Related data
  final ProductVM? product;

  // UI-specific computed properties
  final String displayPrice;
  final String displayTotalPrice;
  final String displayQuantity;
  final String displayProductName;
  final String displayProductImage;

  OrderProductVM({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceSnapshot,
    this.product,
  })  : displayPrice = '\$${priceSnapshot.toStringAsFixed(2)}',
        displayTotalPrice = '\$${(priceSnapshot * quantity).toStringAsFixed(2)}',
        displayQuantity = quantity.toString(),
        displayProductName = product?.name ?? 'Unknown Product',
        displayProductImage = product?.primaryImage ?? 'assets/images/coffee1.png';

  factory OrderProductVM.fromRaw(
    OrderProductModel raw, {
    ProductVM? product,
  }) {
    return OrderProductVM(
      id: raw.id,
      orderId: raw.orderId,
      productId: raw.productId,
      quantity: raw.quantity,
      priceSnapshot: raw.priceSnapshot,
      product: product,
    );
  }

  double get totalPrice => priceSnapshot * quantity;
}
