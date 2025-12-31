part of domain;

class UserModel extends Cacheable {
  final int id;
  final String username;
  final String passwordHash;
  final String? profileImageUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.passwordHash,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });
}
