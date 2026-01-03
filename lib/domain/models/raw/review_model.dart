part of models;

class ReviewModel extends Cacheable {
  final int id;
  final int userId;
  final int merchantId;
  final String? text;
  final double? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.merchantId,
    this.text,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
  });
}
