part of models;

class CreatePostDTO {
  final String? caption;
  final List<int>? productIds;
  final List<MediaModel>? promoMedias;

  CreatePostDTO({this.caption, this.productIds, this.promoMedias});
}

class UpdatePostDTO {
  final String? caption;
  final List<int>? productIds;
  final List<MediaModel>? promoMedias;

  UpdatePostDTO({this.caption, this.productIds, this.promoMedias});
}
