part of domain;

class LiveStreamModel extends Cacheable {
  final int id;
  final int merchantId;
  final String title;
  final String streamUrl;
  final String? thumbnailUrl;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  LiveStreamModel({
    required this.id,
    required this.merchantId,
    required this.title,
    required this.streamUrl,
    this.thumbnailUrl,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });
}
