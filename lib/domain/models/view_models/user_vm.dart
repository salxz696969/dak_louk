part of domain;

class UserVM extends Cacheable {
  final int id;
  final String username;
  final String? profileImageUrl;
  final double rating;
  final String? bio;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  // UI-specific computed properties
  final String displayProfileImage;
  final String displayRating;
  final String displayBio;
  final bool isMerchant;

  UserVM({
    required this.id,
    required this.username,
    this.profileImageUrl,
    required this.rating,
    this.bio,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  })  : displayProfileImage = profileImageUrl ?? 'assets/profiles/profile1.png',
        displayRating = rating.toStringAsFixed(2),
        displayBio = bio ?? '',
        isMerchant = role == 'merchant';

  factory UserVM.fromRaw(UserModel raw) {
    return UserVM(
      id: raw.id,
      username: raw.username,
      profileImageUrl: raw.profileImageUrl,
      rating: raw.rating,
      bio: raw.bio,
      role: raw.role,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
    );
  }

  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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
}
