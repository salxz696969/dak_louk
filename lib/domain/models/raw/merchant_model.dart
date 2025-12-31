part of domain;

class MerchantModel extends Cacheable {
  final int id;
  final int userId;
  final double rating;
  final String? businessName;
  final String? businessDescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantModel({
    required this.id,
    required this.userId,
    required this.rating,
    this.businessName,
    this.businessDescription,
    required this.createdAt,
    required this.updatedAt,
  });
}
