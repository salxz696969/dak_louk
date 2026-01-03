part of models;

class UserProfileVM extends Cacheable {
  final int id;
  final String username;
  final String profileImageUrl;
  final String bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileVM({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    required this.bio,
    required this.createdAt,
    required this.updatedAt,
  });
}
