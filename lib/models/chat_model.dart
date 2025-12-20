import 'package:dak_louk/models/user_model.dart';

class Chat {
  final int id;
  final int userId;
  final String text;
  final int chatRoomId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final User? user;

  Chat({
    required this.id,
    required this.userId,
    required this.text,
    required this.chatRoomId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Chat.fromMap(Map<String, dynamic> chat, User? user) {
    return Chat(
      id: chat['id'],
      userId: chat['user_id'],
      text: chat['text'],
      createdAt: DateTime.parse(chat['created_at']),
      updatedAt: DateTime.parse(chat['updated_at']),
      user: user,
      chatRoomId: chat['chat_room_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'text': text,
      'chat_room_id': chatRoomId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
