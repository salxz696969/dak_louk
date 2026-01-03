part of models;

class UserVM extends Cacheable {
  final int id;
  final String username;
  final String? profileImageUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserVM({
    required this.id,
    required this.username,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserVM.fromRaw(UserModel raw) {
    return UserVM(
      id: raw.id,
      username: raw.username,
      profileImageUrl: raw.profileImageUrl,
      bio: raw.bio,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
    );
  }
}
