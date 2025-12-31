part of domain;

class ChatVM extends Cacheable {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final UserVM? sender;

  // UI-specific computed properties
  final String displaySenderName;
  final String displayProfileImage;
  final String timeAgo;
  final bool isFromCurrentUser;

  ChatVM({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    int? currentUserId,
  })  : displaySenderName = sender?.username ?? 'Unknown',
        displayProfileImage = sender?.displayProfileImage ?? 'assets/profiles/profile1.png',
        timeAgo = _timeAgo(createdAt),
        isFromCurrentUser = currentUserId != null && senderId == currentUserId;

  factory ChatVM.fromRaw(
    ChatModel raw, {
    UserVM? sender,
    int? currentUserId,
  }) {
    return ChatVM(
      id: raw.id,
      chatRoomId: raw.chatRoomId,
      senderId: raw.senderId,
      text: raw.text,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      sender: sender,
      currentUserId: currentUserId,
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
