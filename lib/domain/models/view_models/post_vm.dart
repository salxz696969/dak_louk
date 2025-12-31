part of domain;

class PostVM extends Cacheable {
  final int id;
  final int merchantId;
  final String? caption;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related primitive data
  final String? merchantName;
  final String? merchantProfileImage;
  final List<String>? mediaUrls;
  final List<String>? productNames;
  final int likesCount;
  final int savesCount;
  final bool isLiked;
  final bool isSaved;

  PostVM({
    required this.id,
    required this.merchantId,
    this.caption,
    required this.createdAt,
    required this.updatedAt,
    this.merchantName,
    this.merchantProfileImage,
    this.mediaUrls,
    this.productNames,
    this.likesCount = 0,
    this.savesCount = 0,
    this.isLiked = false,
    this.isSaved = false,
  });

  factory PostVM.fromRaw(
    PostModel raw, {
    String? merchantName,
    String? merchantProfileImage,
    List<String>? mediaUrls,
    List<String>? productNames,
    int likesCount = 0,
    int savesCount = 0,
    bool isLiked = false,
    bool isSaved = false,
  }) {
    return PostVM(
      id: raw.id,
      merchantId: raw.merchantId,
      caption: raw.caption,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      merchantName: merchantName,
      merchantProfileImage: merchantProfileImage,
      mediaUrls: mediaUrls,
      productNames: productNames,
      likesCount: likesCount,
      savesCount: savesCount,
      isLiked: isLiked,
      isSaved: isSaved,
    );
  }

  // Simple getters
  String? get primaryMediaUrl => mediaUrls?.isNotEmpty == true ? mediaUrls!.first : null;
}
