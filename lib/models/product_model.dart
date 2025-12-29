import 'package:dak_louk/models/user_model.dart';
import 'product_category_enum.dart';

class ProductModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final ProductCategory category;
  final double price;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String image;

  final UserModel? user;

  ProductModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.image,
    this.user,
  });

  factory ProductModel.fromMap(Map<String, dynamic> product, String image) {
    return ProductModel(
      id: product['id'],
      userId: product['user_id'],
      title: product['title'],
      description: product['description'],
      category: ProductCategory.values.firstWhere(
        (e) => e.name == product['category'],
      ),
      price: product['price'],
      quantity: product['quantity'],
      image: image,
      createdAt: DateTime.parse(product['created_at']),
      updatedAt: DateTime.parse(product['updated_at']),
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
      'image': image,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

}