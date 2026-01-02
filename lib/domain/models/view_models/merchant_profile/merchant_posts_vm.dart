part of domain;

class MerchantPostsVM {
  final int id;
  final String caption;
  final String imageUrl;

  MerchantPostsVM({
    required this.id,
    required this.caption,
    required this.imageUrl,
  });

  factory MerchantPostsVM.fromRaw(
    PostModel raw, {
    required List<PromoMediaModel> promoMedias,
  }) {
    return MerchantPostsVM(
      id: raw.id,
      caption: raw.caption ?? '',
      imageUrl: promoMedias.isNotEmpty ? promoMedias.first.url : '',
    );
  }
}
