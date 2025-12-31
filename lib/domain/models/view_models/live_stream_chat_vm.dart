part of domain;

class LiveStreamChatVM extends Cacheable {
  final int id;
  final int liveStreamId;
  final int userId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related primitive data
  final String? userName;
  final String? userProfileImage;

  LiveStreamChatVM({
    required this.id,
    required this.liveStreamId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userProfileImage,
  });

  factory LiveStreamChatVM.fromRaw(
    LiveStreamChatModel raw, {
    String? userName,
    String? userProfileImage,
  }) {
    return LiveStreamChatVM(
      id: raw.id,
      liveStreamId: raw.liveStreamId,
      userId: raw.userId,
      text: raw.text,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      userName: userName,
      userProfileImage: userProfileImage,
    );
  }
}
