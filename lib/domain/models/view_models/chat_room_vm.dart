part of domain;

class ChatRoomVM extends Cacheable {
  final int id;
  final int userId;
  final int merchantId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final UserVM? user;
  final UserVM? merchant;
  final ChatVM? lastChat;

  // UI-specific computed properties
  final String displayTargetUserName;
  final String displayTargetUserImage;
  final String displayLastMessage;
  final String displayLastMessageTime;
  final bool hasUnreadMessages;

  ChatRoomVM({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.merchant,
    this.lastChat,
    this.hasUnreadMessages = false,
    int? currentUserId,
  }) : displayTargetUserName = _getTargetUserName(
         user,
         merchant,
         currentUserId,
       ),
       displayTargetUserImage = _getTargetUserImage(
         user,
         merchant,
         currentUserId,
       ),
       displayLastMessage = lastChat?.text ?? 'No messages yet',
       displayLastMessageTime = lastChat?.timeAgo ?? '';

  factory ChatRoomVM.fromRaw(
    ChatRoomModel raw, {
    UserVM? user,
    UserVM? merchant,
    ChatVM? lastChat,
    bool hasUnreadMessages = false,
    int? currentUserId,
  }) {
    return ChatRoomVM(
      id: raw.id,
      userId: raw.userId,
      merchantId: raw.merchantId,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      user: user,
      merchant: merchant,
      lastChat: lastChat,
      hasUnreadMessages: hasUnreadMessages,
      currentUserId: currentUserId,
    );
  }

  static String _getTargetUserName(
    UserVM? user,
    UserVM? merchant,
    int? currentUserId,
  ) {
    if (currentUserId == null) return 'Unknown';

    if (user?.id == currentUserId) {
      return merchant?.username ?? 'Unknown';
    } else {
      return user?.username ?? 'Unknown';
    }
  }

  static String _getTargetUserImage(
    UserVM? user,
    UserVM? merchant,
    int? currentUserId,
  ) {
    if (currentUserId == null) return 'assets/profiles/profile1.png';

    if (user?.id == currentUserId) {
      return merchant?.displayProfileImage ?? 'assets/profiles/profile1.png';
    } else {
      return user?.displayProfileImage ?? 'assets/profiles/profile1.png';
    }
  }

  UserVM? get targetUser {
    // Return the user who is NOT the current user
    if (user?.id != merchantId) {
      return merchant;
    } else {
      return user;
    }
  }
}
