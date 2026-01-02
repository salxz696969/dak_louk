part of domain;

class CartVM extends Cacheable {
  final CartMerchantVM merchant;
  final List<CartItemVM> items;

  CartVM({required this.merchant, required this.items});
  factory CartVM.fromRaw(
    CartModel raw, {
    required CartMerchantVM merchant,
    required List<CartItemVM> items,
  }) {
    return CartVM(merchant: merchant, items: items);
  }
}

class CartItemVM {
  final int id;
  final int userId;
  final int productId;
  final String name;
  final double price;
  final String image;
  final int quantity;
  final int availableQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItemVM({
    required this.id,
    required this.userId,
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.availableQuantity,
    required this.createdAt,
    required this.updatedAt,
  });
}

class CartMerchantVM {
  final int id;
  final String username;
  final String profileImage;

  CartMerchantVM({
    required this.id,
    required this.username,
    required this.profileImage,
  });

  factory CartMerchantVM.fromRaw(MerchantModel raw) {
    return CartMerchantVM(
      id: raw.id,
      username: raw.username,
      profileImage: raw.profileImage,
    );
  }
}
