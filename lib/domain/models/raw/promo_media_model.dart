part of models;

// This represents promo_medias table
class PromoMediaModel extends Cacheable {
  final int id;
  final int postId;
  final String url;
  final String? mediaType;
  final DateTime createdAt;
  final DateTime updatedAt;

  PromoMediaModel({
    required this.id,
    required this.postId,
    required this.url,
    this.mediaType,
    required this.createdAt,
    required this.updatedAt,
  });
}
