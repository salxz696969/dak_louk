part of models;

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
}

class PostProductVM extends Cacheable{
  final int id;
  final String name;
  final List<MediaModel> medias;
  final double price;
  final int quantity;
  final String description;
  final ProductCategory category;
  final bool isAddedToCart;

  PostProductVM({
    required this.id,
    required this.name,
    required this.medias,
    required this.price,
    required this.quantity,
    required this.description,
    required this.category,
    required this.isAddedToCart,
  });

  factory PostProductVM.fromRaw(
    ProductModel raw, {
    required List<MediaModel> medias,
    required ProductCategory category,
    required bool isAddedToCart,
  }) {
    return PostProductVM(
      id: raw.id,
      name: raw.name,
      medias: medias,
      price: raw.price,
      quantity: raw.quantity,
      description: raw.description ?? '',
      category: category,
      isAddedToCart: isAddedToCart,
    );
  }
}

class PostMerchantVM extends Cacheable{
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
