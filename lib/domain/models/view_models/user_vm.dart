part of domain;

class UserVM extends Cacheable {
  final int id;
  final String username;
  final String? profileImageUrl;
  final double rating;
  final String? bio;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserVM({
    required this.id,
    required this.username,
    this.profileImageUrl,
    required this.rating,
    this.bio,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserVM.fromRaw(UserModel raw) {
    return UserVM(
      id: raw.id,
      username: raw.username,
      profileImageUrl: raw.profileImageUrl,
      rating: raw.rating,
      bio: raw.bio,
      role: raw.role,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
    );
  }
}
