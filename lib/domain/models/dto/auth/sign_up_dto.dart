part of domain;

class SignUpDTO {
  final String username;
  final String email;
  final String password;
  final String phone;
  final String address;
  final String profileImageUrl;
  final String bio;

  SignUpDTO({
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.profileImageUrl,
    required this.bio,
  });
}
