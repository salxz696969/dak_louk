part of domain;

class CreateProductMediaDTO {
  final String url;
  final String? mediaType;

  CreateProductMediaDTO({
    required this.url,
    this.mediaType,
  });
}

class UpdateProductMediaDTO {
  final String? url;
  final String? mediaType;

  UpdateProductMediaDTO({this.url, this.mediaType});
}
