part of domain;

class CreateLiveStreamDTO {
  final String title;
  final String streamUrl;
  final String? thumbnailUrl;
  final int viewCount;

  CreateLiveStreamDTO({
    required this.title,
    required this.streamUrl,
    this.thumbnailUrl,
    this.viewCount = 0,
  });
}

class UpdateLiveStreamDTO {
  final String? title;
  final String? streamUrl;
  final String? thumbnailUrl;
  final int? viewCount;

  UpdateLiveStreamDTO({
    this.title,
    this.streamUrl,
    this.thumbnailUrl,
    this.viewCount,
  });
}
