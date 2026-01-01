part of domain;

class PostLikeModel extends Cacheable {
  final int id;
  final int userId;
  final int postId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostLikeModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
  });
}
