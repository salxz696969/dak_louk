part of domain;

class ProductMediaVM extends Cacheable {
  final int id;
  final int productId;
  final String url;
  final String? mediaType;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductMediaVM({
    required this.id,
    required this.productId,
    required this.url,
    this.mediaType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductMediaVM.fromRaw(ProductMediaModel raw) {
    return ProductMediaVM(
      id: raw.id,
      productId: raw.productId,
      url: raw.url,
      mediaType: raw.mediaType,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
    );
  }

  // Simple getters
  bool get isVideo => mediaType == 'video';
  bool get isImage => mediaType == 'image' || mediaType == null;
}
