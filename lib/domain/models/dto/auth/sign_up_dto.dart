part of domain;

class SignUpDTO {
  final String username;
  final String email;
  final String password;
  final String profileImageUrl;
  final String bio;

  SignUpDTO({
    required this.username,
    required this.email,
    required this.password,
    required this.profileImageUrl,
    required this.bio,
  });
}
