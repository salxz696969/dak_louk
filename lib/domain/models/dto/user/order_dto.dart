part of models;

class CreateOrderDTO {
  final int merchantId;
  final String? address;
  final String? phone;
  final String? notes;
  final List<OrderProductDTO> orderItems;

  CreateOrderDTO({
    required this.merchantId,
    this.address,
    this.phone,
    this.notes,
    required this.orderItems,
  });
}
// only merchatt use this

class UpdateOrderDTO {
  final String? status;

  UpdateOrderDTO({this.status});
}
