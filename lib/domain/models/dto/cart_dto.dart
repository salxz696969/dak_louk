part of domain;

class CreateCartDTO {
  final int userId;
  final int productId;
  final int quantity;

  CreateCartDTO({
    required this.userId,
    required this.productId,
    this.quantity = 1,
  });
}

class UpdateCartDTO {
  final int? quantity;

  UpdateCartDTO({
    this.quantity,
  });
}
