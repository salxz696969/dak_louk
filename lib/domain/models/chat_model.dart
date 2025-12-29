part of domain;

class ChatModel extends Cacheable {
  final int id;
  final int userId;
  final String text;
  final int chatRoomId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final UserModel? user;

  ChatModel({
    required this.id,
    required this.userId,
    required this.text,
    required this.chatRoomId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });
}
