part of models;

class CreateProductDTO {
  final String name;
  final String? description;
  final double price;
  final int quantity;
  final String? imageUrl;

  CreateProductDTO({
    required this.name,
    this.description,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
  });
}

class UpdateProductDTO {
  final String? name;
  final String? description;
  final double? price;
  final int? quantity;
  final String? imageUrl;

  UpdateProductDTO({
    this.name,
    this.description,
    this.price,
    this.quantity,
    this.imageUrl,
  });
}
