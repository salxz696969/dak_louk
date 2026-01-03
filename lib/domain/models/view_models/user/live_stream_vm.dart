part of models;

class LiveStreamVM extends Cacheable {
  final int id;
  final int merchantId;
  final String title;
  final String streamUrl;
  final String? thumbnailUrl;
  final int viewCount;
  final String createdAt;
  final String updatedAt;

  // Related primitive data
  final String? merchantName;
  final String? merchantProfileImage;
  final List<String>? productNames;
  final int chatCount;

  LiveStreamVM({
    required this.id,
    required this.merchantId,
    required this.title,
    required this.streamUrl,
    this.thumbnailUrl,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    this.merchantName,
    this.merchantProfileImage,
    this.productNames,
    this.chatCount = 0,
  });

  factory LiveStreamVM.fromRaw(
    LiveStreamModel raw, {
    String? merchantName,
    String? merchantProfileImage,
    List<String>? productNames,
    int chatCount = 0,
  }) {
    return LiveStreamVM(
      id: raw.id,
      merchantId: raw.merchantId,
      title: raw.title,
      streamUrl: raw.streamUrl,
      thumbnailUrl: raw.thumbnailUrl,
      viewCount: raw.viewCount,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      merchantName: merchantName,
      merchantProfileImage: merchantProfileImage,
      productNames: productNames,
      chatCount: chatCount,
    );
  }
}
