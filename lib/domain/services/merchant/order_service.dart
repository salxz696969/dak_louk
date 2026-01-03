import 'package:dak_louk/data/repositories/cart_repo.dart';
import 'package:dak_louk/core/enums/order_status_enum.dart';
import 'package:dak_louk/data/repositories/order_product_repo.dart';
import 'package:dak_louk/data/repositories/order_repo.dart';
import 'package:dak_louk/data/repositories/merchant_repo.dart';
import 'package:dak_louk/data/repositories/product_media_repo.dart';
import 'package:dak_louk/data/repositories/product_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/domain/services/user/user_service.dart';

class OrderService {
  late final currentMerchantId;
  final OrderRepository _orderRepository = OrderRepository();
  final OrderProductRepository _orderProductRepository =
      OrderProductRepository();
  final CartRepository _cartRepository = CartRepository();
  final MerchantRepository _merchantRepository = MerchantRepository();
  final ProductRepository _productRepository = ProductRepository();
  final ProductMediaRepository _productMediaRepository =
      ProductMediaRepository();

  OrderService() {
    if (AppSession.instance.isLoggedIn &&
        AppSession.instance.merchantId != null) {
      currentMerchantId = AppSession.instance.merchantId;
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

      return enrichedOrders;
    } catch (e, stack) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(type: ErrorType.DB_ERROR, message: 'Failed to get orders');
    }
  }

  Future<OrderVM?> getOrderById(int id) async {
    // Placeholder - implement later
    throw UnimplementedError('getOrderById not implemented');
  }

  Future<OrderVM?> createOrder(CreateOrderDTO dto) async {
    // Placeholder - implement later
    throw UnimplementedError('createOrder not implemented');
  }

  Future<OrderVM?> updateOrder(int id, UpdateOrderDTO dto) async {
    // Placeholder - implement later
    throw UnimplementedError('updateOrder not implemented');
  }

  Future<void> deleteOrder(int id) async {
    // Placeholder - implement later
    throw UnimplementedError('deleteOrder not implemented');
  }

  Future<OrderVM?> updateOrderStatus(int orderId, String newStatus) async {
    // fuck the orm thing implement it yourself
    throw UnimplementedError('updateOrderStatus not implemented');
  }
}
