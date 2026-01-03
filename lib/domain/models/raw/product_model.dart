part of models;

class ProductModel extends Cacheable {
  final int id;
  final int merchantId;
  final String name;
  final String? description;
  final double price;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.merchantId,
    required this.name,
    this.description,
    required this.price,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });
}
