part of models;

class CreateCartDTO {
  final int productId;
  final int quantity;

  CreateCartDTO({required this.productId, this.quantity = 1});
}

class UpdateCartDTO {
  final int? quantity;

  UpdateCartDTO({this.quantity});
}
