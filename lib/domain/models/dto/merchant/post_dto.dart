part of models;

class CreatePostDTO {
  final String? caption;
  final List<PostProductVM>? product;
  final List<PromoMediaVM>? promoMedia;

  CreatePostDTO({this.caption, this.product, this.promoMedia});
}

class UpdatePostDTO {
  final String? caption;
  final List<PostProductVM>? product;
  final List<PromoMediaVM>? promoMedia;

  UpdatePostDTO({this.caption, this.product, this.promoMedia});
}
