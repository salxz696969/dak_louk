part of domain;

class PostVM extends Cacheable {
  final int id;
  final int merchantId;
  final String? caption;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final UserVM? merchant;
  final List<ProductVM>? products;
  final List<PromoMediaVM>? medias;
  final int? likesCount;
  final int? savesCount;
  final bool? isLiked;
  final bool? isSaved;

  // UI-specific computed properties
  final String displayCaption;
  final String timeAgo;
  final List<String> displayImages;
  final String primaryImage;

  PostVM({
    required this.id,
    required this.merchantId,
    this.caption,
    required this.createdAt,
    required this.updatedAt,
    this.merchant,
    this.products,
    this.medias,
    this.likesCount,
    this.savesCount,
    this.isLiked,
    this.isSaved,
  }) : displayCaption = caption ?? '',
       timeAgo = _timeAgo(createdAt),
       displayImages =
           medias?.map((m) => m.url).toList() ?? ['assets/promo/coffee1.jpg'],
       primaryImage = medias?.isNotEmpty == true
           ? medias!.first.url
           : 'assets/promo/coffee1.jpg';

  factory PostVM.fromRaw(
    PostModel raw, {
    UserVM? merchant,
    List<ProductVM>? products,
    List<PromoMediaVM>? medias,
    int? likesCount,
    int? savesCount,
    bool? isLiked,
    bool? isSaved,
  }) {
    return PostVM(
      id: raw.id,
      merchantId: raw.merchantId,
      caption: raw.caption,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      merchant: merchant,
      products: products,
      medias: medias,
      likesCount: likesCount,
      savesCount: savesCount,
      isLiked: isLiked,
      isSaved: isSaved,
    );
  }

  static String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  String get displayLikesCount => likesCount?.toString() ?? '0';
  String get displaySavesCount => savesCount?.toString() ?? '0';
  ProductVM? get primaryProduct =>
      products?.isNotEmpty == true ? products!.first : null;
}
