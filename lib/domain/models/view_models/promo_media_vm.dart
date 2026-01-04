part of models;

class PromoMediaVM extends Cacheable {
  final int id;
  final int postId;
  final String url;
  final MediaType? mediaType;
  final DateTime createdAt;
  final DateTime updatedAt;

  PromoMediaVM({
    required this.id,
    required this.postId,
    required this.url,
    this.mediaType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PromoMediaVM.fromRaw(PromoMediaModel raw) {
    return PromoMediaVM(
      id: raw.id,
      postId: raw.postId,
      url: raw.url,
      mediaType: raw.mediaType == 'video' ? MediaType.video : MediaType.image,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
    );
  }

  // Simple getters
  bool get isVideo => mediaType == MediaType.video;
  bool get isImage => mediaType == MediaType.image;
}
