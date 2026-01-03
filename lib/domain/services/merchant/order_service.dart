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

  Future<List<OrderVM>> getAllOrders() async {
    // Placeholder - implement later
    throw UnimplementedError('getAllOrders not implemented');
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
}
