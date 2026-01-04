import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/data/repositories/cart_repo.dart';
import 'package:dak_louk/data/repositories/product_repo.dart';
import 'package:dak_louk/data/repositories/merchant_repo.dart';
import 'package:dak_louk/data/repositories/product_media_repo.dart';
import 'package:dak_louk/data/cache/cache.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/core/utils/error.dart';

class CartService {
  final CartRepository _cartRepository = CartRepository();
  final ProductRepository _productRepository = ProductRepository();
  final MerchantRepository _merchantRepository = MerchantRepository();
  final ProductMediaRepository _productMediaRepository =
      ProductMediaRepository();
  final Cache _cache = Cache();
  late final currentUserId;
  late final String _baseCacheKey;

  CartService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
      _baseCacheKey = 'service:user:$currentUserId:cart';
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  Future<List<CartVM>> getCarts() async {
    try {
      final cacheKey = '$_baseCacheKey:getCarts';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectMany(cached).cast<CartVM>().toList();
      }

      // Get all cart items for the current user
      final statement = Clauses.where.eq(
        Tables.carts.cols.userId,
        currentUserId,
      );
      final cartItems = await _cartRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );

      if (cartItems.isEmpty) {
        return [];
      }

      // Group cart items by merchant
      final Map<int, List<Map<String, dynamic>>> cartsByMerchant = {};

      for (final cartItem in cartItems) {
        // Get the product to find its merchant
        final product = await _productRepository.getById(cartItem.productId);

        if (product != null) {
          final merchantId = product.merchantId;

          // Get product media (first image)
          final productMedias = await _productMediaRepository.queryThisTable(
            where: Clauses.where
                .eq(Tables.productMedias.cols.productId, product.id)
                .clause,
            args: Clauses.where
                .eq(Tables.productMedias.cols.productId, product.id)
                .args,
          );

          final productImage = productMedias.isNotEmpty
              ? productMedias.first.url
              : 'assets/images/placeholder.png';

          if (!cartsByMerchant.containsKey(merchantId)) {
            cartsByMerchant[merchantId] = [];
          }

          cartsByMerchant[merchantId]!.add({
            'cartItem': cartItem,
            'product': product,
            'productImage': productImage,
          });
        }
      }

      // Build CartVM list grouped by merchant
      final List<CartVM> cartVMs = [];

      for (final entry in cartsByMerchant.entries) {
        final merchantId = entry.key;
        final merchantCartData = entry.value;

        // Get merchant details
        final merchant = await _merchantRepository.getById(merchantId);

        if (merchant != null) {
          // Create CartMerchantVM
          final merchantVM = CartMerchantVM.fromRaw(merchant);

          // Create CartItemVM list with product details
          final itemVMs = merchantCartData.map((data) {
            final cartItem = data['cartItem'] as CartModel;
            final product = data['product'] as ProductModel;
            final productImage = data['productImage'] as String;

            return CartItemVM(
              id: cartItem.id,
              userId: cartItem.userId,
              productId: cartItem.productId,
              name: product.name,
              price: product.price,
              image: productImage,
              quantity: cartItem.quantity,
              availableQuantity: product.quantity,
              createdAt: DateTime.parse(cartItem.createdAt),
              updatedAt: DateTime.parse(cartItem.updatedAt),
            );
          }).toList();

          // Create CartVM
          cartVMs.add(CartVM(merchant: merchantVM, items: itemVMs));
        }
      }

      _cache.set(cacheKey, Many(cartVMs));
      return cartVMs;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get carts: ${e.toString()}',
      );
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

  Future<int?> createCart(CreateCartDTO dto) async {
    try {
      final cartModel = CartModel(
        id: 0,
        userId: currentUserId,
        productId: dto.productId,
        quantity: dto.quantity,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      final id = await _cartRepository.insert(cartModel);
      if (id > 0) {
        final newCart = await _cartRepository.getById(id);
        if (newCart != null) {
          return newCart.id;
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

  Future<int?> updateCart(int id, UpdateCartDTO dto) async {
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
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _cartRepository.update(cartModel);
      final newCart = await _cartRepository.getById(id);
      if (newCart != null) {
        return newCart.id;
      }
      return null;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to update cart',
      );
    }
  }
}
