part of domain;

class CreateOrderProductDTO {
  final int orderId;
  final int productId;
  final int quantity;
  final double priceSnapshot;

  CreateOrderProductDTO({
    required this.orderId,
    required this.productId,
    this.quantity = 1,
    required this.priceSnapshot,
  });
}

class UpdateOrderProductDTO {
  final int? quantity;
  final double? priceSnapshot;

  UpdateOrderProductDTO({this.quantity, this.priceSnapshot});
}
