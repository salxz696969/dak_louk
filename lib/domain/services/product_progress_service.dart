import 'package:dak_louk/data/repositories/order_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ProductProgressService {
  final OrderRepository _orderRepository = OrderRepository();

  // Business logic methods migrated from ProductProgressRepository
  Future<List<OrderModel>> getProductProgressesByUserId(int userId) async {
    try {
      final statement = Clauses.where.eq(Tables.orders.cols.userId, userId);
      final progresses = await _orderRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.orders.cols.createdAt).clause,
      );

      // Populate relations
      final enrichedProgresses = await Future.wait(
        progresses.map((progress) async {
          return OrderModel(
            id: progress.id,
            userId: progress.userId,
            merchantId: progress.merchantId,
            status: progress.status,
            createdAt: progress.createdAt,
            updatedAt: progress.updatedAt,
          );
        }),
      );

      return enrichedProgresses;
    } catch (e) {
      rethrow;
    }
  }
}
