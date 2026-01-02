part of domain;

class MerchantVM extends Cacheable {
  final int id;
  final String username;
  final String profileImage;
  final String bio;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantVM({
    required this.id,
    required this.username,
    required this.profileImage,
    required this.bio,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantVM.fromRaw(MerchantModel raw) {
    return MerchantVM(
      id: raw.id,
      username: raw.username,
      profileImage: raw.profileImage,
      bio: raw.bio,
      rating: raw.rating,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
    );
  }
}
