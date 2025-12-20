import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/models/progress_status_enum.dart';
import 'package:dak_louk/models/user_model.dart';

class ProductProgress {
  final int id;
  final int userId;
  final int productId;
  final ProgressStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  final User? user;
  final Product? product;

  ProductProgress({
    required this.id,
    required this.userId,
    required this.productId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.product,
  });

  factory ProductProgress.fromMap(
    Map<String, dynamic> productProgress,
    User? user,
    Product? product,
  ) {
    return ProductProgress(
      id: productProgress['id'],
      userId: productProgress['user_id'],
      productId: productProgress['product_id'],
      status: ProgressStatus.values.firstWhere(
        (e) => e.toString() == 'ProgressStatus.${productProgress['status']}',
      ),
      createdAt: DateTime.parse(productProgress['created_at']),
      updatedAt: DateTime.parse(productProgress['updated_at']),
      user: user,
      product: product,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
