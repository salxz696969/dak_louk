part of models;

class FollowerModel extends Cacheable {
  final int id;
  final int followerId;
  final int followedId;
  final DateTime createdAt;
  final DateTime updatedAt;

  FollowerModel({
    required this.id,
    required this.followerId,
    required this.followedId,
    required this.createdAt,
    required this.updatedAt,
  });
}
