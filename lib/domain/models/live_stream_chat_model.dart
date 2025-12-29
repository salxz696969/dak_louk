part of domain;

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
}
