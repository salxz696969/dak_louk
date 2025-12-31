import 'package:dak_louk/data/repositories/order_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';

class ProductProgressService {
  late final currentUserId;
  final OrderRepository _orderRepository = OrderRepository();
  OrderService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  // Business logic methods migrated from ProductProgressRepository
  Future<List<OrderVM>> getProductProgressesByUserId(int userId) async {
    try {
      if (userId != currentUserId) {
        throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
      }
      final statement = Clauses.where.eq(Tables.orders.cols.userId, userId);
      final progresses = await _orderRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.orders.cols.createdAt).clause,
      );

      // Populate relations
      final enrichedProgresses = await Future.wait(
        progresses.map((progress) async {
          return OrderVM.fromRaw(progress);
        }),
      );

      return enrichedProgresses;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get product progresses by user id',
      );
    }
  }
}
