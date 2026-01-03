part of models;

class OrderModel extends Cacheable {
  final int id;
  final int userId;
  final int merchantId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
