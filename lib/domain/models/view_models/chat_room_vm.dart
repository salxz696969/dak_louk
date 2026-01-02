part of domain;

class ChatRoomVM extends Cacheable {
  final int id;
  final String merchantName;
  final String merchantProfileImage;
  final String timeAgo;
  final String latestText;

  ChatRoomVM({
    required this.id,
    required this.merchantName,
    required this.merchantProfileImage,
    required this.timeAgo,
    required this.latestText,
  });

  factory ChatRoomVM.fromRaw(
    ChatRoomModel raw, {
    required String merchantName,
    required String merchantProfileImage,
    required String timeAgo,
    required String latestText,
  }) {
    return ChatRoomVM(
      id: raw.id,
      merchantName: merchantName,
      merchantProfileImage: merchantProfileImage,
      timeAgo: timeAgo,
      latestText: latestText,
    );
  }
}
