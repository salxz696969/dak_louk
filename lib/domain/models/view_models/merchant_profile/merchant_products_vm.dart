part of domain;

class MerchantProductsVM {
  final int id;
  final String name;
  final String image;
  final int quantity;
  final double price;

  MerchantProductsVM({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
  });

  factory MerchantProductsVM.fromRaw(
    ProductModel raw, {
    required List<ProductMediaVM> productMedias,
  }) {
    return MerchantProductsVM(
      id: raw.id,
      name: raw.name,
      image: productMedias.isNotEmpty ? productMedias.first.url : '',
      quantity: raw.quantity,
      price: raw.price,
    );
  }
}
