part of models;

class ChatModel extends Cacheable {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String text;
  final String createdAt;
  final String updatedAt;

  ChatModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });
}
