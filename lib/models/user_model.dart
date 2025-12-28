class UserModel {
  final int id;
  final String username;
  final String passwordHash;
  final String profileImageUrl;
  final double rating;
  final String role;
  final String bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.profileImageUrl,
    required this.rating,
    required this.role,
    required this.bio,
    required this.createdAt,
    required this.updatedAt,
  });
}
