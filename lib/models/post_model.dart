import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/models/user_model.dart';

class Post {
  final int id;
  final int userId;
  final String title;
  final String productId;

  final Product? product;
  final User? user;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.productId,
    this.product,
    this.user,
  });

  factory Post.fromMap(Map<String, dynamic> post, Product? product, User? user) {
    return Post(
      id: post['id'],
      userId: post['user_id'],
      title: post['title'],
      productId: post['product_id'],
      product: product,
      user: user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'product_id': productId,
    };
  }
}
