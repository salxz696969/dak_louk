part of models;

class LiveStreamProductsVM extends Cacheable {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final String image;

  LiveStreamProductsVM({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });
  factory LiveStreamProductsVM.fromRaw(
    LiveStreamProductModel raw, {
    required String image,
    required String name,
    required double price,
    required int quantity,
  }) {
    return LiveStreamProductsVM(
      id: raw.id,
      name: name,
      price: price,
      quantity: quantity,
      image: image,
    );
  }
}
