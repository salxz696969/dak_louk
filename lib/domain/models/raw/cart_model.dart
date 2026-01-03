part of models;

class CartModel extends Cacheable {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final String createdAt;
  final String updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });
}
