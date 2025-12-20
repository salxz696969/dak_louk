import 'package:dak_louk/models/user_model.dart';

class ChatRoom {
  final int id;
  final int userId;
  final int targetUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final User? user;
  final User? targetUser;

  ChatRoom({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.user,
    required this.targetUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoom.fromMap(
    Map<String, dynamic> chatRoom,
    User? user,
    User? targetUser,
  ) {
    return ChatRoom(
      id: chatRoom['id'],
      userId: chatRoom['user_id'],
      targetUserId: chatRoom['target_user_id'],
      createdAt: DateTime.parse(chatRoom['created_at']),
      updatedAt: DateTime.parse(chatRoom['updated_at']),
      user: user,
      targetUser: targetUser,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'target_user_id': targetUserId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
