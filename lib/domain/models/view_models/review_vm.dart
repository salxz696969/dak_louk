part of domain;

class ReviewVM extends Cacheable {
  final int id;
  final int userId;
  final int merchantId;
  final String? text;
  final double? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final UserVM? user;
  final UserVM? merchant;

  // UI-specific computed properties
  final String displayText;
  final String displayRating;
  final String displayUserName;
  final String displayUserImage;
  final String displayMerchantName;
  final String timeAgo;
  final int starRating;

  ReviewVM({
    required this.id,
    required this.userId,
    required this.merchantId,
    this.text,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.merchant,
  })  : displayText = text ?? '',
        displayRating = rating?.toStringAsFixed(1) ?? '0.0',
        displayUserName = user?.username ?? 'Anonymous',
        displayUserImage = user?.displayProfileImage ?? 'assets/profiles/profile1.png',
        displayMerchantName = merchant?.username ?? 'Unknown Merchant',
        timeAgo = _timeAgo(createdAt),
        starRating = (rating?.round() ?? 0).clamp(0, 5);

  factory ReviewVM.fromRaw(
    ReviewModel raw, {
    UserVM? user,
    UserVM? merchant,
  }) {
    return ReviewVM(
      id: raw.id,
      userId: raw.userId,
      merchantId: raw.merchantId,
      text: raw.text,
      rating: raw.rating,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      user: user,
      merchant: merchant,
    );
  }

  static String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  bool get hasText => text != null && text!.isNotEmpty;
  bool get hasRating => rating != null && rating! > 0;
  bool get isPositive => rating != null && rating! >= 4.0;
  bool get isNegative => rating != null && rating! <= 2.0;
}
