part of domain;

class LiveStreamVM extends Cacheable {
  final int id;
  final int merchantId;
  final String title;
  final String streamUrl;
  final String? thumbnailUrl;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final UserVM? merchant;
  final List<ProductVM>? products;
  final List<LiveStreamChatVM>? chats;

  // UI-specific computed properties
  final String displayThumbnail;
  final String displayViewCount;
  final String timeAgo;

  LiveStreamVM({
    required this.id,
    required this.merchantId,
    required this.title,
    required this.streamUrl,
    this.thumbnailUrl,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    this.merchant,
    this.products,
    this.chats,
  })  : displayThumbnail = thumbnailUrl ?? 'assets/thumbnails/default.png',
        displayViewCount = _formatViewCount(viewCount),
        timeAgo = _timeAgo(createdAt);

  factory LiveStreamVM.fromRaw(
    LiveStreamModel raw, {
    UserVM? merchant,
    List<ProductVM>? products,
    List<LiveStreamChatVM>? chats,
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
      merchant: merchant,
      products: products,
      chats: chats,
    );
  }

  static String _formatViewCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
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

  ProductVM? get primaryProduct => products?.isNotEmpty == true ? products!.first : null;
}
