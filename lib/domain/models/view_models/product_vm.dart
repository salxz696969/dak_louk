part of domain;

class ProductVM extends Cacheable {
  final int id;
  final int merchantId;
  final String name;
  final String? description;
  final double price;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final UserVM? merchant;
  final List<ProductMediaVM>? medias;
  final List<String>? categories;

  // UI-specific computed properties
  final String displayPrice;
  final String displayQuantity;
  final String displayDescription;
  final List<String> displayImages;
  final String primaryImage;

  ProductVM({
    required this.id,
    required this.merchantId,
    required this.name,
    this.description,
    required this.price,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.merchant,
    this.medias,
    this.categories,
  })  : displayPrice = '\$${price.toStringAsFixed(2)}',
        displayQuantity = quantity.toString(),
        displayDescription = description ?? '',
        displayImages = medias?.map((m) => m.url).toList() ?? ['assets/images/coffee1.png'],
        primaryImage = medias?.isNotEmpty == true ? medias!.first.url : 'assets/images/coffee1.png';

  factory ProductVM.fromRaw(
    ProductModel raw, {
    UserVM? merchant,
    List<ProductMediaVM>? medias,
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
      merchant: merchant,
      medias: medias,
      categories: categories,
    );
  }

  String get categoriesDisplay => categories?.join(', ') ?? '';
  
  bool get isInStock => quantity > 0;
  
  String get stockStatus => isInStock ? 'In Stock' : 'Out of Stock';
}
