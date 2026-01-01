part of domain;

class PostVM extends Cacheable {
  final int id;
  final int merchantId;
  final String? caption;
  final List<PromoMediaModel>? promoMedias;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int savesCount;
  final bool isLiked;
  final bool isSaved;

  // Related primitive data
  final PostMerchantVM merchant;
  final List<PostProductVM> products;

  PostVM({
    required this.id,
    required this.merchantId,
    this.caption,
    this.promoMedias,
    required this.createdAt,
    required this.updatedAt,
    required this.merchant,
    required this.products,
    required this.likesCount,
    required this.savesCount,
    required this.isLiked,
    required this.isSaved,
  });

  factory PostVM.fromRaw(
    PostModel raw, {
    List<PromoMediaModel>? promoMedias,
    required PostMerchantVM merchant,
    required List<PostProductVM> products,
    required int likesCount,
    required int savesCount,
    required bool isLiked,
    required bool isSaved,
  }) {
    return PostVM(
      id: raw.id,
      merchantId: raw.merchantId,
      caption: raw.caption,
      promoMedias: promoMedias,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      merchant: merchant,
      products: products,
      likesCount: likesCount,
      savesCount: savesCount,
      isLiked: isLiked,
      isSaved: isSaved,
    );
  }

  // Simple getters
  String? get primaryMediaUrl =>
      products.isNotEmpty ? products.first.imageUrls.first : null;
}

class PostProductVM {
  final int id;
  final String name;
  final List<String> imageUrls;
  final String price;
  final String quantity;
  final String description;
  final ProductCategory category;

  PostProductVM({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.price,
    required this.quantity,
    required this.description,
    required this.category,
  });
}

class PostMerchantVM {
  final int id;
  final String name;
  final String bio;
  final String profileImage;
  final String username;
  final double rating;

  PostMerchantVM({
    required this.id,
    required this.name,
    required this.bio,
    required this.profileImage,
    required this.username,
    required this.rating,
  });
}
