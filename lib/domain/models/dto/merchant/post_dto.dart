part of models;

class CreatePostDTO {
  final String? caption;
  final List<int>? productIds;
  final List<String>? promoMediaUrls;

  CreatePostDTO({this.caption, this.productIds, this.promoMediaUrls});
}

class UpdatePostDTO {
  final String? caption;
  final List<int>? productIds;
  final List<String>? promoMediaUrls;

  UpdatePostDTO({this.caption, this.productIds, this.promoMediaUrls});
}
