part of domain;

// This represents product_medias table
class ProductMediaModel extends Cacheable {
  final int id;
  final int productId;
  final String url;
  final String? mediaType;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductMediaModel({
    required this.id,
    required this.productId,
    required this.url,
    this.mediaType,
    required this.createdAt,
    required this.updatedAt,
  });
}
