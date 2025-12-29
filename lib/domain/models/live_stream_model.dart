part of domain;

class LiveStreamModel  extends Cacheable {
  final int id;
  final String url;
  final int userId;
  final String title;
  final String thumbnailUrl;
  final int view;
  final DateTime createdAt;
  final DateTime updatedAt;

  final UserModel? user;
  final List<ProductModel>? products;
  final List<LiveStreamChatModel>? liveStreamChats;

  LiveStreamModel({
    required this.id,
    required this.url,
    required this.userId,
    required this.title,
    required this.thumbnailUrl,
    required this.view,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.products,
    this.liveStreamChats,
  });

  static String timeAgo(DateTime date) {
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

  LiveStreamUI ui() {
    final user = this.user;
    final products = this.products ?? [];
    final liveStreamChats = this.liveStreamChats ?? [];

    // Use AssetImage for local assets, fallback if needed
    final thumbnail = (thumbnailUrl.isNotEmpty)
        ? thumbnailUrl
        : 'assets/thumbnails/default.png';

    final profileImage =
        (user?.profileImageUrl != null && user!.profileImageUrl.isNotEmpty)
        ? user.profileImageUrl
        : 'assets/profiles/profile1.png';

    final username = user?.username ?? 'Unknown';
    final rating = user?.rating.toStringAsFixed(2) ?? '0.00';

    // Use first product if available
    final product = products.isNotEmpty ? products.first : null;
    final quantity = product?.quantity.toString() ?? '1';
    final price = product?.price.toStringAsFixed(2) ?? '0.0';
    final description = product?.description ?? '';
    final title = this.title;
    final category = product?.category.name;
    final productId = product?.id ?? 0;
    final date = LiveStreamModel.timeAgo(createdAt);

    return LiveStreamUI(
      thumbnail: thumbnail,
      url: url,
      title: title,
      user: user!,
      products: products,
      liveStreamChats: liveStreamChats,
      timeAgo: date,
      profileImage: profileImage,
      username: username,
      rating: rating,
      view: view.toString(),
      quantity: quantity,
      price: price,
      description: description,
      category: category,
      productId: productId,
    );
  }
}

class LiveStreamUI  extends Cacheable {
  final String thumbnail;
  final String url;
  final String title;
  final UserModel user;
  final List<ProductModel> products;
  final List<LiveStreamChatModel> liveStreamChats;
  final String timeAgo;
  final String view;

  // Additional fields for UI, similar to PostUI
  final String profileImage;
  final String username;
  final String rating;
  final String quantity;
  final String price;
  final String description;
  final String? category;
  final int productId;

  LiveStreamUI({
    required this.thumbnail,
    required this.url,
    required this.title,
    required this.user,
    required this.products,
    required this.liveStreamChats,
    required this.timeAgo,
    required this.profileImage,
    required this.view,
    required this.username,
    required this.rating,
    required this.quantity,
    required this.price,
    required this.description,
    required this.category,
    required this.productId,
  });
}
