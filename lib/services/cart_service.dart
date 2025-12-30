import 'package:dak_louk/db/repositories/cart_repo.dart';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';
import 'package:dak_louk/utils/error.dart';

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
      throw AppError(type: ErrorType.NOT_FOUND, message: 'No carts found');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCart(int id) async {
    try {
      await _cartRepository.delete(id);
    } catch (e) {
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to delete cart',
      );
    }
  }

  Future<CartModel?> createCart(CartModel cart) async {
    try {
      final id = await _cartRepository.insert(cart);
      final newCart = await _cartRepository.getById(id);
      if (newCart != null) {
        return newCart;
      }
      return null;
    } catch (e) {
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create cart',
      );
    }
  }

  Future<CartModel?> updateCart(CartModel cart) async {
    try {
      await _cartRepository.update(cart);
      final newCart = await _cartRepository.getById(cart.id);
      if (newCart != null) {
        return newCart;
      }
      return null;
    } catch (e) {
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to update cart',
      );
    }
  }
}
