part of models;

class MerchantLiveStreamsVM extends Cacheable {
  final int id;
  final String title;
  final String streamUrl;
  final String? thumbnailUrl;
  final int viewCount;
  final String createdAt;
  final String updatedAt;

  final List<MerchantLiveStreamsProductsVM>? products;

  MerchantLiveStreamsVM({
    required this.id,
    required this.title,
    required this.streamUrl,
    this.thumbnailUrl,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    this.products,
  });

  factory MerchantLiveStreamsVM.fromRaw(
    LiveStreamModel raw, {
    List<MerchantLiveStreamsProductsVM>? products,
  }) {
    return MerchantLiveStreamsVM(
      id: raw.id,
      title: raw.title,
      streamUrl: raw.streamUrl,
      thumbnailUrl: raw.thumbnailUrl,
      viewCount: raw.viewCount,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      products: products,
    );
  }
}

class MerchantLiveStreamsProductsVM extends Cacheable {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final List<String> imageUrls;

  MerchantLiveStreamsProductsVM({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrls,
  });

  factory MerchantLiveStreamsProductsVM.fromRaw(
    LiveStreamProductModel raw, {
    required String name,
    required double price,
    required int quantity,
    required List<String> imageUrls,
  }) {
    return MerchantLiveStreamsProductsVM(
      id: raw.id,
      name: name,
      price: price,
      quantity: quantity,
      imageUrls: imageUrls,
    );
  }
}
