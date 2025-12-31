part of domain;

class OrderProductModel extends Cacheable {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double priceSnapshot;

  OrderProductModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceSnapshot,
  });
}
