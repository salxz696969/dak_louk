part of models;

class LiveStreamChatModel extends Cacheable {
  final int id;
  final int liveStreamId;
  final int userId;
  final String text;
  final String createdAt;
  final String updatedAt;

  LiveStreamChatModel({
    required this.id,
    required this.liveStreamId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });
}
