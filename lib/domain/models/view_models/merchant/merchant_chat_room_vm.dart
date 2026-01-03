part of models;

class MerchantChatRoomVM extends Cacheable {
  final int id;
  final String buyerName;
  final String buyerProfileImage;
  final String timeAgo;
  final String latestText;

  MerchantChatRoomVM({
    required this.id,
    required this.buyerName,
    required this.buyerProfileImage,
    required this.timeAgo,
    required this.latestText,
  });

  factory MerchantChatRoomVM.fromRaw(
    ChatRoomModel raw, {
    required String buyerName,
    required String buyerProfileImage,
    required String timeAgo,
    required String latestText,
  }) {
    return MerchantChatRoomVM(
      id: raw.id,
      buyerName: buyerName,
      buyerProfileImage: buyerProfileImage,
      timeAgo: timeAgo,
      latestText: latestText,
    );
  }
}
