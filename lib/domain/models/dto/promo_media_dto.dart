part of domain;

class CreatePromoMediaDTO {
  final int postId;
  final String url;
  final String? mediaType;

  CreatePromoMediaDTO({
    required this.postId,
    required this.url,
    this.mediaType,
  });
}

class UpdatePromoMediaDTO {
  final String? url;
  final String? mediaType;

  UpdatePromoMediaDTO({
    this.url,
    this.mediaType,
  });
}
