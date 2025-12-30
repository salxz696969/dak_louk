part of domain;

class MediaModel extends Cacheable {
  final int id;
  final String url;
  final int postId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaModel({
    required this.id,
    required this.url,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
  });
}
