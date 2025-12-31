part of domain;

class ChatRoomVM extends Cacheable {
  final int id;
  final int userId;
  final int merchantId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related primitive data
  final String? targetUserName;
  final String? targetUserProfileImage;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool hasUnreadMessages;

  ChatRoomVM({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.createdAt,
    required this.updatedAt,
    this.targetUserName,
    this.targetUserProfileImage,
    this.lastMessage,
    this.lastMessageTime,
    this.hasUnreadMessages = false,
  });

  factory ChatRoomVM.fromRaw(
    ChatRoomModel raw, {
    String? targetUserName,
    String? targetUserProfileImage,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool hasUnreadMessages = false,
  }) {
    return ChatRoomVM(
      id: raw.id,
      userId: raw.userId,
      merchantId: raw.merchantId,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      targetUserName: targetUserName,
      targetUserProfileImage: targetUserProfileImage,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      hasUnreadMessages: hasUnreadMessages,
    );
  }
}
