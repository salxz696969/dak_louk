part of models;

class MerchantLiveStreamsVM extends Cacheable {
  final int id;
  final String title;
  final String streamUrl;
  final String? thumbnailUrl;
  final int viewCount;
  final String createdAt;
  final String updatedAt;

  MerchantLiveStreamsVM({
    required this.id,
    required this.title,
    required this.streamUrl,
    this.thumbnailUrl,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantLiveStreamsVM.fromRaw(LiveStreamModel raw) {
    return MerchantLiveStreamsVM(
      id: raw.id,
      title: raw.title,
      streamUrl: raw.streamUrl,
      thumbnailUrl: raw.thumbnailUrl,
      viewCount: raw.viewCount,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
    );
  }
}
