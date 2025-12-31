import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/data/repositories/cart_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/core/utils/error.dart';

class CartService {
  final CartRepository _cartRepository = CartRepository();
  late final currentUserId;

  CartService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  Future<List<CartVM>> getCarts() async {
    try {
      final carts = await _cartRepository.queryThisTable(
        where: Clauses.where.eq(Tables.carts.cols.userId, currentUserId).clause,
      );
      if (carts.isNotEmpty) {
        return carts.map((cart) => CartVM.fromRaw(cart)).toList();
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
      final cart = await _cartRepository.getById(id);
      if (cart == null) {
        throw AppError(type: ErrorType.NOT_FOUND, message: 'Cart not found');
      }
      if (cart.userId != currentUserId) {
        throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
      }
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

  Future<CartVM?> createCart(CreateCartDTO dto) async {
    try {
      final cartModel = CartModel(
        id: 0,
        userId: currentUserId,
        productId: dto.productId,
        quantity: dto.quantity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await _cartRepository.insert(cartModel);
      if (id > 0) {
        final newCart = await _cartRepository.getById(id);
        if (newCart != null) {
          return CartVM.fromRaw(newCart);
        }
        throw AppError(type: ErrorType.NOT_FOUND, message: 'Cart not found');
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create cart',
      );
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

  Future<CartVM?> updateCart(int id, UpdateCartDTO dto) async {
    try {
      final cart = await _cartRepository.getById(id);
      if (cart == null) {
        throw AppError(type: ErrorType.NOT_FOUND, message: 'Cart not found');
      }
      if (cart.userId != currentUserId) {
        throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
      }
      final cartModel = CartModel(
        id: id,
        userId: currentUserId,
        productId: cart.productId,
        quantity: dto.quantity ?? cart.quantity,
        createdAt: cart.createdAt,
        updatedAt: DateTime.now(),
      );
      await _cartRepository.update(cartModel);
      final newCart = await _cartRepository.getById(id);
      if (newCart != null) {
        return CartVM.fromRaw(newCart);
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
