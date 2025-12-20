import 'package:dak_louk/models/user_model.dart';

class ChatRoom {
  final int id;
  final int userId;
  final int targetUserId;

  final User? user;
  final User? targetUser;

  ChatRoom({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.user,
    required this.targetUser,
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
      user: user,
      targetUser: targetUser,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'user_id': userId, 'target_user_id': targetUserId};
  }
}
