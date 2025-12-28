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
}
