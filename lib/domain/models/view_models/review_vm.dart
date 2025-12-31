part of domain;

class ReviewVM extends Cacheable {
  final int id;
  final int userId;
  final int merchantId;
  final String? text;
  final double? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related primitive data
  final String? userName;
  final String? userProfileImage;
  final String? merchantName;

  ReviewVM({
    required this.id,
    required this.userId,
    required this.merchantId,
    this.text,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userProfileImage,
    this.merchantName,
  });

  factory ReviewVM.fromRaw(
    ReviewModel raw, {
    String? userName,
    String? userProfileImage,
    String? merchantName,
  }) {
    return ReviewVM(
      id: raw.id,
      userId: raw.userId,
      merchantId: raw.merchantId,
      text: raw.text,
      rating: raw.rating,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      userName: userName,
      userProfileImage: userProfileImage,
      merchantName: merchantName,
    );
  }

  // Simple getters
  int get starRating => (rating?.round() ?? 0).clamp(0, 5);
}
