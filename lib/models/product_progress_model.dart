import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/models/progress_status_enum.dart';
import 'package:dak_louk/models/user_model.dart';

class ProductProgressModel {
  final int id;
  final int userId;
  final int productId;
  final ProgressStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  final UserModel? user;
  final ProductModel? product;

  ProductProgressModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.product,
  });
}
