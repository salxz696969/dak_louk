part of models;

class OrderProductModel extends Cacheable {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;

  OrderProductModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
  });
}
