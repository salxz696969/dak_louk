part of domain;

class MerchantProductsVM {
  final int id;
  final String name;
  final String image;
  final int quantity;
  final double price;
  final bool isAddedToCart;

  MerchantProductsVM({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
    required this.isAddedToCart,
  });

  factory MerchantProductsVM.fromRaw(
    ProductModel raw, {
    required List<ProductMediaVM> productMedias,
    required bool isAddedToCart,
  }) {
    return MerchantProductsVM(
      id: raw.id,
      name: raw.name,
      image: productMedias.isNotEmpty ? productMedias.first.url : '',
      quantity: raw.quantity,
      price: raw.price,
      isAddedToCart: isAddedToCart,
    );
  }
}
