part of domain;

class UserModel extends Cacheable {
  final int id;
  final String username;
  final String passwordHash;
  final String? profileImageUrl;
  final double rating;
  final String? bio;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.passwordHash,
    this.profileImageUrl,
    required this.rating,
    this.bio,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });
}
