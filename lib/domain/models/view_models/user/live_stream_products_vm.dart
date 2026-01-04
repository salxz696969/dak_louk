part of models;

class LiveStreamProductsVM extends Cacheable {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final List<MediaModel> medias;

  LiveStreamProductsVM({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.medias,
  });
  factory LiveStreamProductsVM.fromRaw(
    LiveStreamProductModel raw, {
    required List<MediaModel> medias,
    required String name,
    required double price,
    required int quantity,
  }) {
    return LiveStreamProductsVM(
      id: raw.id,
      name: name,
      price: price,
      quantity: quantity,
      medias: medias,
    );
  }
}
