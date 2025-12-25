import 'package:dak_louk/models/user_model.dart';

class ChatRoomModel {
  final int id;
  final int userId;
  final int targetUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final UserModel? user;
  final UserModel? targetUser;

  ChatRoomModel({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.user,
    required this.targetUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoomModel.fromMap(
    Map<String, dynamic> chatRoom,
    UserModel? user,
    UserModel? targetUser,
  ) {
    return ChatRoomModel(
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
