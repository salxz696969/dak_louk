class User {
  final int id;
  final String username;
  final String passwordHash;
  final String profileImageUrl;
  final double rating;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.profileImageUrl,
    required this.rating,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> user) {
    return User(
      id: user['id'],
      username: user['username'],
      passwordHash: user['password_hash'],
      profileImageUrl: user['profile_image_url'],
      rating: user['rating'],
      role: user['role'],
      createdAt: DateTime.parse(user['created_at']),
      updatedAt: DateTime.parse(user['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'profile_image_url': profileImageUrl,
      'rating': rating,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
