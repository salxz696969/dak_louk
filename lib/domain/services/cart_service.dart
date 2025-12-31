import 'package:dak_louk/data/repositories/cart_repo.dart';
import 'package:dak_louk/domain/models/index.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/core/utils/error.dart';

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
      if (e is AppError) {
        rethrow;
      }
      rethrow;
    }
  }

  Future<void> deleteCart(int id) async {
    try {
      await _cartRepository.delete(id);
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
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
      if (e is AppError) {
        rethrow;
      }
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
