part of domain;

class CreateOrderDTO {
  final int merchantId;
  final String status;

  CreateOrderDTO({required this.merchantId, this.status = 'waiting'});
}

class UpdateOrderDTO {
  final String? status;

  UpdateOrderDTO({this.status});
}
