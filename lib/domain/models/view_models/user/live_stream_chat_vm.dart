part of models;

class LiveStreamChatVM extends Cacheable {
  final int id;
  final String username;
  final String profileImage;
  final String text;
  LiveStreamChatVM({
    required this.id,
    required this.username,
    required this.profileImage,
    required this.text,
  });

  factory LiveStreamChatVM.fromRaw(
    LiveStreamChatModel raw, {
    required String username,
    required String profileImage,
  }) {
    return LiveStreamChatVM(
      id: raw.id,
      username: username,
      profileImage: profileImage,
      text: raw.text,
    );
  }
}
