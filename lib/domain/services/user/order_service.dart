import 'package:dak_louk/data/repositories/cart_repo.dart';
import 'package:dak_louk/core/enums/order_status_enum.dart';
import 'package:dak_louk/data/repositories/order_product_repo.dart';
import 'package:dak_louk/data/repositories/order_repo.dart';
import 'package:dak_louk/data/repositories/merchant_repo.dart';
import 'package:dak_louk/data/repositories/product_media_repo.dart';
import 'package:dak_louk/data/repositories/product_repo.dart';
import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';

class OrderService {
  late final currentUserId;
  final OrderRepository _orderRepository = OrderRepository();
  final OrderProductRepository _orderProductRepository =
      OrderProductRepository();
  final CartRepository _cartRepository = CartRepository();
  final MerchantRepository _merchantRepository = MerchantRepository();
  final ProductRepository _productRepository = ProductRepository();
  final ProductMediaRepository _productMediaRepository =
      ProductMediaRepository();
  final UserRepository _userRepository = UserRepository();
  OrderService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  // Business logic methods migrated from ProductProgressRepository
  Future<List<OrderVM>> getAllOrders() async {
    try {
      final statement = Clauses.where.eq(
        Tables.orders.cols.userId,
        currentUserId,
      );

      final orders = await _orderRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.orders.cols.createdAt).clause,
      );

      final List<OrderVM> enrichedOrders = [];
      for (final order in orders) {
        try {
          final merchant = await _merchantRepository.getById(order.merchantId);

          final orderProductModels = await _orderProductRepository
              .queryThisTable(
                where: Clauses.where
                    .eq(Tables.orderProducts.cols.orderId, order.id)
                    .clause,
                args: Clauses.where
                    .eq(Tables.orderProducts.cols.orderId, order.id)
                    .args,
              );

          int totalPrice = 0;
          final orderProductsVM = <OrderProductVM>[];

          for (final op in orderProductModels) {
            final products = await _productRepository.queryThisTable(
              where: Clauses.where
                  .eq(Tables.products.cols.id, op.productId)
                  .clause,
              args: Clauses.where
                  .eq(Tables.products.cols.id, op.productId)
                  .args,
            );
            final product = products.isNotEmpty ? products.first : null;
            if (product == null) {
              continue;
            }

            final medias = await _productMediaRepository.queryThisTable(
              where: Clauses.where
                  .eq(Tables.productMedias.cols.productId, product.id)
                  .clause,
              args: Clauses.where
                  .eq(Tables.productMedias.cols.productId, product.id)
                  .args,
            );
            final productMedia = medias.isNotEmpty ? medias.first : null;

            totalPrice += (product.price * op.quantity).toInt();

            orderProductsVM.add(
              OrderProductVM.fromRaw(
                op,
                productName: product.name,
                productImageUrl: productMedia != null ? productMedia.url : '',
              ),
            );
          }

          final user = await _userRepository.getById(order.userId);
          final orderVM = OrderVM.fromRaw(
            order,
            username: 'placeholder name',
            userProfileImage: user?.profileImageUrl ?? 'assets/images/coffee1.png',
            merchantName: merchant?.username ?? '',
            merchantProfileImage: merchant?.profileImage ?? '',
            products: orderProductsVM,
            totalPrice: totalPrice,
          );
          enrichedOrders.add(orderVM);
        } catch (orderEx) {
          rethrow;
        }
      }

      return enrichedOrders;
    } catch (e, stack) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(type: ErrorType.DB_ERROR, message: 'Failed to get orders');
    }
  }

  Future<void> createOrders(List<CreateOrderDTO> dtos) async {
    for (final dto in dtos) {
      final order = OrderModel(
        id: 0,
        userId: currentUserId,
        merchantId: dto.merchantId,
        status: OrderStatusEnum.waiting.name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final orderId = await _orderRepository.insert(order);
      if (orderId <= 0) {
        throw AppError(
          type: ErrorType.DB_ERROR,
          message: 'Failed to create order',
        );
      }
      for (final item in dto.orderItems) {
        final orderProduct = OrderProductModel(
          id: 0,
          orderId: orderId,
          productId: item.productId,
          quantity: item.quantity,
        );
        final orderProductId = await _orderProductRepository.insert(
          orderProduct,
        );
        // delete prducts in cart
        final carts = await _cartRepository.getAll();
        for (final cart in carts) {
          if (cart.productId == item.productId &&
              cart.userId == currentUserId) {
            await _cartRepository.delete(cart.id);
          }
        }
        if (orderProductId <= 0) {
          throw AppError(
            type: ErrorType.DB_ERROR,
            message: 'Failed to create order product',
          );
        }
      }
    }
  }
}
