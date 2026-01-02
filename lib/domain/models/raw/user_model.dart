part of domain;

class UserModel extends Cacheable {
  final int id;
  final String username;
  final String passwordHash;
  final String? profileImageUrl;
  final String? phone;
  final String? address;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.passwordHash,
    this.profileImageUrl,
    this.bio,
    this.phone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });
}
