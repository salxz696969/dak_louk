part of domain;

class ChatRoomModel extends Cacheable {
  final int id;
  final int userId;
  final int targetUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final bool? areYouLatestToChat;
  final String? latestChat;
  final UserModel? user;
  final UserModel? targetUser;

  ChatRoomModel({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.targetUser,
    this.areYouLatestToChat,
    this.latestChat,
  });

  factory ChatRoomModel.fromMap(
    Map<String, dynamic> chatRoom,
    UserModel? user,
    UserModel? targetUser,
    bool? areYouLatestToChat,
    String? latestChat,
  ) {
    return ChatRoomModel(
      id: chatRoom['id'],
      userId: chatRoom['user_id'],
      targetUserId: chatRoom['target_user_id'],
      createdAt: DateTime.parse(chatRoom['created_at']),
      updatedAt: DateTime.parse(chatRoom['updated_at']),
      user: user,
      targetUser: targetUser,
      areYouLatestToChat: areYouLatestToChat,
      latestChat: latestChat,
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

  ChatRoomUI ui() {
    return ChatRoomUI(
      targetUserName: targetUser?.username ?? '',
      targetUserAvatarUrl: targetUser?.profileImageUrl ?? '',
      latestChat: latestChat ?? '',
      areYouLatestToChat: areYouLatestToChat ?? false,
    );
  }
}

class ChatRoomUI {
  final String targetUserName;
  final String targetUserAvatarUrl;
  final String latestChat;
  final bool areYouLatestToChat;

  ChatRoomUI({
    required this.targetUserName,
    required this.targetUserAvatarUrl,
    required this.latestChat,
    required this.areYouLatestToChat,
  });
}
