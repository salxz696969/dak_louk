part of models;

class LiveStreamProductModel extends Cacheable {
  final int id;
  final int liveStreamId;
  final int productId;

  LiveStreamProductModel({
    required this.id,
    required this.liveStreamId,
    required this.productId,
  });
}
