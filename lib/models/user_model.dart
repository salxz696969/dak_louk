class User {
  final int id;
  final String username;
  final String passwordHash;
  final String profileImageUrl;
  final double rating;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.profileImageUrl,
    required this.rating,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> user) {
    return User(
      id: user['id'],
      username: user['username'],
      passwordHash: user['password_hash'],
      profileImageUrl: user['profile_image_url'],
      rating: user['rating'],
      role: user['role'],
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
    };
  }
}
