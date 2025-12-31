part of domain;

class LiveStreamChatVM extends Cacheable {
  final int id;
  final int liveStreamId;
  final int userId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final UserVM? user;

  // UI-specific computed properties
  final String displayUsername;
  final String displayProfileImage;
  final String timeAgo;

  LiveStreamChatVM({
    required this.id,
    required this.liveStreamId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  })  : displayUsername = user?.username ?? 'Unknown',
        displayProfileImage = user?.displayProfileImage ?? 'assets/profiles/profile1.png',
        timeAgo = _timeAgo(createdAt);

  factory LiveStreamChatVM.fromRaw(
    LiveStreamChatModel raw, {
    UserVM? user,
  }) {
    return LiveStreamChatVM(
      id: raw.id,
      liveStreamId: raw.liveStreamId,
      userId: raw.userId,
      text: raw.text,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      user: user,
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
}
