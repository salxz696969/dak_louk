// on ly merchant use this

part of models;

class CreateLiveStreamDTO {
  final String title;
  final String streamUrl;
  final String? thumbnailUrl;

  final List<int>? productIds;

  CreateLiveStreamDTO({
    required this.title,
    required this.streamUrl,
    this.productIds,
    this.thumbnailUrl,
  });
}

class UpdateLiveStreamDTO {
  final String? title;
  final String? streamUrl;
  final String? thumbnailUrl;
  final List<int>? productIds;

  UpdateLiveStreamDTO({
    this.title,
    this.streamUrl,
    this.thumbnailUrl,
    this.productIds,
  });
}
