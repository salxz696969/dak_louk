part of domain;

class CreateProductDTO {
  final int merchantId;
  final String name;
  final String? description;
  final double price;
  final int quantity;

  CreateProductDTO({
    required this.merchantId,
    required this.name,
    this.description,
    required this.price,
    this.quantity = 1,
  });
}

class UpdateProductDTO {
  final String? name;
  final String? description;
  final double? price;
  final int? quantity;

  UpdateProductDTO({
    this.name,
    this.description,
    this.price,
    this.quantity,
  });
}
