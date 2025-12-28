import 'package:dak_louk/db/repositories/repository_base.dart';
import 'package:dak_louk/db/repositories/product_dao.dart';
import 'package:dak_louk/db/repositories/user_dao.dart';
import 'package:dak_louk/models/cart_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class CartDao extends BaseRepository<CartModel> {
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

  // Custom methods using queryThisTable
  Future<List<CartModel>> getCartsByUserId(int userId) async {
    try {
      final statement = Clauses.where.eq(Tables.carts.cols.userId, userId);
      final carts = await queryThisTable(
        where: statement.clause,
        args: statement.args,
      );

      return carts;
    } catch (e) {
      rethrow;
    }
  }
}
