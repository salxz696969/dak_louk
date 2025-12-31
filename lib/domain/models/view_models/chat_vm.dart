part of domain;

class ChatVM extends Cacheable {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related primitive data
  final String? senderName;
  final String? senderProfileImage;
  final bool isFromCurrentUser;

  ChatVM({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.senderName,
    this.senderProfileImage,
    this.isFromCurrentUser = false,
  });

  factory ChatVM.fromRaw(
    ChatModel raw, {
    String? senderName,
    String? senderProfileImage,
    bool isFromCurrentUser = false,
  }) {
    return ChatVM(
      id: raw.id,
      chatRoomId: raw.chatRoomId,
      senderId: raw.senderId,
      text: raw.text,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      senderName: senderName,
      senderProfileImage: senderProfileImage,
      isFromCurrentUser: isFromCurrentUser,
    );
  }
}
