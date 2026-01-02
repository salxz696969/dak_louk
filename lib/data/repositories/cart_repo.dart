import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/tables/tables.dart';

class CartRepository extends BaseRepository<CartModel> {
  @override
  String get tableName => Tables.carts.tableName;

  @override
  CartModel fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map[Tables.carts.cols.id] as int,
      userId: map[Tables.carts.cols.userId] as int,
      productId: map[Tables.carts.cols.productId] as int,
      quantity: map[Tables.carts.cols.quantity] as int,
      createdAt: map[Tables.carts.cols.createdAt] as String,
      updatedAt: map[Tables.carts.cols.updatedAt] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(CartModel model) {
    return {
      Tables.carts.cols.id: model.id,
      Tables.carts.cols.userId: model.userId,
      Tables.carts.cols.productId: model.productId,
      Tables.carts.cols.quantity: model.quantity,
      Tables.carts.cols.createdAt: model.createdAt,
      Tables.carts.cols.updatedAt: model.updatedAt,
    };
  }
}
