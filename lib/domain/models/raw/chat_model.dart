part of domain;

class ChatModel extends Cacheable {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });
}
