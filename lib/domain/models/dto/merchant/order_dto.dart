part of models;

class CreateOrderDTO {
  final int merchantId;
  final String? address;
  final String? phone;
  final String? notes;
  final List<CreateOrderProductDTO> orderItems;

  CreateOrderDTO({
    required this.merchantId,
    this.address,
    this.phone,
    this.notes,
    required this.orderItems,
  });
}

class CreateOrderProductDTO {
  final int productId;
  final int quantity;

  CreateOrderProductDTO({required this.productId, required this.quantity});
}

// only merchatt use this

class UpdateOrderDTO {
  final String? status;

  UpdateOrderDTO({this.status});
}
