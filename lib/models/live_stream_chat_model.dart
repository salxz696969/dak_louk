import 'package:dak_louk/models/user_model.dart';

class LiveStreamChatModel {
  final int id;
  final String text;
  final int userId;
  final int liveStreamId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final UserModel? user;

  LiveStreamChatModel({
    required this.id,
    required this.text,
    required this.userId,
    required this.liveStreamId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory LiveStreamChatModel.fromMap(
    Map<String, dynamic> liveStreamChat,
    UserModel? user,
  ) {
    return LiveStreamChatModel(
      id: liveStreamChat['id'],
      text: liveStreamChat['text'],
      userId: liveStreamChat['user_id'],
      liveStreamId: liveStreamChat['live_stream_id'],
      createdAt: DateTime.parse(liveStreamChat['created_at']),
      updatedAt: DateTime.parse(liveStreamChat['updated_at']),
      user: user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'user_id': userId,
      'live_stream_id': liveStreamId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
