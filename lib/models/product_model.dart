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

  final int? liveStreamId;
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
    this.liveStreamId,
    this.user,
  });
}
