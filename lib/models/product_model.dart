import 'product_category_enum.dart';

class Product {
  final int id;
  final int userId;
  final String title;
  final String description;
  final ProductCategory category;
  final double price;
  final int quantity;
  final int liveStreamId;

  Product({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.liveStreamId,
  });

  factory Product.fromMap(Map<String, dynamic> product) {
    return Product(
      id: product['id'],
      userId: product['user_id'],
      title: product['title'],
      description: product['description'],
      category: ProductCategory.values.firstWhere(
        (e) => e.name == product['category'],
      ),
      price: product['price'],
      quantity: product['quantity'],
      liveStreamId: product['live_stream_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category.name,
      'price': price,
      'quantity': quantity,
      'live_stream_id': liveStreamId,
    };
  }
}
