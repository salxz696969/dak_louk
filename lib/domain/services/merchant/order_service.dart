import 'package:dak_louk/data/repositories/order_product_repo.dart';
import 'package:dak_louk/data/repositories/order_repo.dart';
import 'package:dak_louk/data/repositories/product_media_repo.dart';
import 'package:dak_louk/data/repositories/product_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/domain/services/user/user_service.dart';
import 'package:dak_louk/data/cache/cache.dart';

class OrderService {
  late final currentMerchantId;
  final OrderRepository _orderRepository = OrderRepository();
  final OrderProductRepository _orderProductRepository =
      OrderProductRepository();
  final ProductRepository _productRepository = ProductRepository();
  final ProductMediaRepository _productMediaRepository =
      ProductMediaRepository();
  final Cache _cache = Cache();
  late final String _baseCacheKey;

  OrderService() {
    if (AppSession.instance.isLoggedIn &&
        AppSession.instance.merchantId != null) {
      currentMerchantId = AppSession.instance.merchantId;
      _baseCacheKey = 'service:merchant:$currentMerchantId:order';
    } else {
      throw AppError(
        type: ErrorType.UNAUTHORIZED,
        message: 'Unauthorized - No merchant session',
      );
    }
  }

  // CRUD Operations for Orders

  Future<List<OrderMerchantVM>> getAllOrders() async {
    try {
      final cacheKey = '$_baseCacheKey:getAllOrders';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectMany(cached).cast<OrderMerchantVM>().toList();
      }

      final statement = Clauses.where
          .eq(Tables.orders.cols.merchantId, currentMerchantId)
          .and([
            Clauses.where.neq(Tables.orders.cols.status, 'completed'),
            Clauses.where.neq(Tables.orders.cols.status, 'cancelled'),
          ]);

      final orders = await _orderRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy
            .caseWhen(Tables.orders.cols.status, {
              'waiting': 1,
              'delivering': 2,
            }, elseValue: 3)
            .thenBy(Clauses.orderBy.desc(Tables.orders.cols.createdAt).clause)
            .clause,
      );

      final List<OrderMerchantVM> enrichedOrders = [];
      for (final order in orders) {
        try {
          final user = await UserService().getUserById(order.userId);
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
          final orderProductsVM = <OrderProductMerchantVM>[];

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
              OrderProductMerchantVM.fromRaw(
                op,
                productName: product.name,
                productImageUrl: productMedia != null ? productMedia.url : '',
              ),
            );
          }

          final orderVM = OrderMerchantVM.fromRaw(
            order,
            username: user?.username ?? '',
            userProfileImage: user?.profileImageUrl ?? '',
            products: orderProductsVM,
            totalPrice: totalPrice,
          );
          enrichedOrders.add(orderVM);
        } catch (orderEx) {
          rethrow;
        }
      }

      _cache.set(cacheKey, Many(enrichedOrders));
      return enrichedOrders;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(type: ErrorType.DB_ERROR, message: 'Failed to get orders');
    }
  }

  Future<void> updateOrder(int id, UpdateOrderDTO dto) async {
    try {
      final order = await _orderRepository.getById(id);
      if (order == null) {
        throw AppError(type: ErrorType.NOT_FOUND, message: 'Order not found');
      }
      if (order.merchantId != currentMerchantId) {
        throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
      }
      await _orderRepository.update(
        OrderModel(
          id: id,
          merchantId: currentMerchantId,
          status: dto.status ?? order.status,
          userId: order.userId,
          createdAt: order.createdAt,
          updatedAt: DateTime.now(),
        ),
      );

      // Invalidate cache
      _cache.del('$_baseCacheKey:getAllOrders');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to update order',
      );
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      await _orderRepository.delete(id);

      // Invalidate cache
      _cache.del('$_baseCacheKey:getAllOrders');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to delete order',
      );
    }
  }
}
