part of domain;

class MerchantModel extends Cacheable {
  final int id;
  final int userId;
  final double rating;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantModel({
    required this.id,
    required this.userId,
    required this.rating,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });
}
