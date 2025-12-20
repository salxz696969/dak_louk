import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/models/user_model.dart';

class Post {
  final int id;
  final int userId;
  final String title;
  final int productId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final List<String>? images;
  final Product? product;
  final User? user;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
    this.images,
    this.product,
    this.user,
  });

  factory Post.fromMap(
    Map<String, dynamic> post,
    Product? product,
    User? user,
    List<String>? images,
  ) {
    return Post(
      id: post['id'],
      userId: post['user_id'],
      title: post['title'],
      productId: post['product_id'],
      createdAt: DateTime.parse(post['created_at']),
      updatedAt: DateTime.parse(post['updated_at']),
      product: product,
      user: user,
      images: images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'product_id': productId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
