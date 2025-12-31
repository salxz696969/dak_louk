part of domain;

class CreateUserDTO {
  final String username;
  final String passwordHash;
  final String? profileImageUrl;
  final double rating;
  final String? bio;
  final String role;

  CreateUserDTO({
    required this.username,
    required this.passwordHash,
    this.profileImageUrl,
    this.rating = 0.0,
    this.bio,
    this.role = 'user',
  });
}

class UpdateUserDTO {
  final String? username;
  final String? passwordHash;
  final String? profileImageUrl;
  final double? rating;
  final String? bio;
  final String? role;

  UpdateUserDTO({
    this.username,
    this.passwordHash,
    this.profileImageUrl,
    this.rating,
    this.bio,
    this.role,
  });
}
