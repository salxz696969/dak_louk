part of domain;

class CreatePostDTO {
  final int merchantId;
  final String? caption;

  CreatePostDTO({
    required this.merchantId,
    this.caption,
  });
}

class UpdatePostDTO {
  final String? caption;

  UpdatePostDTO({
    this.caption,
  });
}
