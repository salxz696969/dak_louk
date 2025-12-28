import 'package:dak_louk/db/repositories/cart_repo.dart';
import 'package:dak_louk/models/cart_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class CartService {
  final CartRepository _cartRepository = CartRepository();

  // Custom methods using queryThisTable
  Future<List<CartModel>> getCartsByUserId(int userId) async {
    try {
      final statement = Clauses.where.eq(Tables.carts.cols.userId, userId);
      final carts = await _cartRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );

      if (carts.isNotEmpty) {
        return carts;
      }
      throw Exception('No carts found');
    } catch (e) {
      rethrow;
    }
  }
}
