part of domain;

class PostModel  extends Cacheable{
  final int id;
  final int userId;
  final String title;
  final int productId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final int? liveStreamId;
  final List<String>? images;
  final ProductModel? product;
  final UserModel? user;

  PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
    this.liveStreamId,
    this.images,
    this.product,
    this.user,
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

  PostUI ui() {
    final user = this.user;
    final product = this.product;
    final images = this.images ?? [];

    final profileImage = (user?.profileImageUrl != null)
        ? user!.profileImageUrl
        : 'assets/profiles/profile1.png';

    final username = user?.username ?? 'Unknown';
    final rating = user?.rating.toStringAsFixed(2) ?? '0.00';

    final quantity = product?.quantity.toString() ?? '1';
    final price = product?.price.toStringAsFixed(2) ?? '0.0';
    final description = product?.description ?? '';
    final title = this.title;
    final category = this.product?.category.name;
    final productId = this.product?.id;
    final date = timeAgo(createdAt);

    return PostUI(
      bio: user?.bio ?? '',
      userId: userId,
      profileImage: profileImage,
      username: username,
      rating: rating,
      quantity: quantity,
      price: price,
      description: description,
      title: title,
      category: category,
      date: date,
      images: images,
      productId: productId ?? 0,
    );
  }
}

class PostUI  extends Cacheable {
  final String profileImage;
  final int userId;
  final String username;
  final String rating;
  final String quantity;
  final String price;
  final String description;
  final String title;
  final String? category;
  final String date;
  final List<String> images;
  final int productId;
  final String bio;

  PostUI({
    required this.bio,
    required this.profileImage,
    required this.username,
    required this.rating,
    required this.quantity,
    required this.price,
    required this.description,
    required this.title,
    required this.category,
    required this.date,
    required this.images,
    required this.userId,
    required this.productId,
  });
}
