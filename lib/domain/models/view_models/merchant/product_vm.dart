part of models;

class ProductVM extends Cacheable {
  final int id;
  final int merchantId;
  final String name;
  final String? description;
  final double price;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related primitive data
  final String? merchantName;
  final String? merchantProfileImage;
  final List<String>? mediaUrls;
  final List<String>? categories;

  ProductVM({
    required this.id,
    required this.merchantId,
    required this.name,
    this.description,
    required this.price,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.merchantName,
    this.merchantProfileImage,
    this.mediaUrls,
    this.categories,
  });

  factory ProductVM.fromRaw(
    ProductModel raw, {
    String? merchantName,
    String? merchantProfileImage,
    List<String>? mediaUrls,
    List<String>? categories,
  }) {
    return ProductVM(
      id: raw.id,
      merchantId: raw.merchantId,
      name: raw.name,
      description: raw.description,
      price: raw.price,
      quantity: raw.quantity,
      createdAt: raw.createdAt,
      updatedAt: raw.updatedAt,
      merchantName: merchantName,
      merchantProfileImage: merchantProfileImage,
      mediaUrls: mediaUrls,
      categories: categories,
    );
  }

  // Simple getters
  String? get primaryImageUrl =>
      mediaUrls?.isNotEmpty == true ? mediaUrls!.first : null;
}
