part of domain;

class PostModel extends Cacheable {
  final int id;
  final int merchantId;
  final String? caption;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.merchantId,
    this.caption,
    required this.createdAt,
    required this.updatedAt,
  });
}
