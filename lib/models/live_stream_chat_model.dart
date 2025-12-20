import 'package:dak_louk/models/user_model.dart';

class LiveStreamChat{
  final int id;
  final String text;
  final int userId;
  final int liveStreamId;

  final User? user;

  LiveStreamChat({
    required this.id,
    required this.text,
    required this.userId,
    required this.liveStreamId,
    this.user,
  });

  factory LiveStreamChat.fromMap(Map<String, dynamic> liveStreamChat, User? user) {
    return LiveStreamChat(
      id: liveStreamChat['id'],
      text: liveStreamChat['text'],
      userId: liveStreamChat['user_id'],
      liveStreamId: liveStreamChat['live_stream_id'],
      user: user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'user_id': userId,
      'live_stream_id': liveStreamId,
    };
  }
}