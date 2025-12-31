import 'package:dak_louk/db/repositories/product_progress_dao.dart';
import 'package:dak_louk/db/repositories/product_repo.dart';
import 'package:dak_louk/db/repositories/user_repo.dart';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class ProductProgressService {
  final ProductProgressRepository _productProgressRepository =
      ProductProgressRepository();
  final ProductRepository _productRepository = ProductRepository();
  final UserRepository _userRepository = UserRepository();

  // Business logic methods migrated from ProductProgressRepository
  Future<List<ProductProgressModel>> getProductProgressesByUserId(
    int userId,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.productProgress.cols.userId,
        userId,
      );
      final progresses = await _productProgressRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy
            .desc(Tables.productProgress.cols.createdAt)
            .clause,
      );

      // Populate relations
      final enrichedProgresses = await Future.wait(
        progresses.map((progress) async {
          final product = await _productRepository.getById(progress.productId);
          final user = await _userRepository.getById(progress.userId);

          return ProductProgressModel(
            id: progress.id,
            userId: progress.userId,
            productId: progress.productId,
            status: progress.status,
            createdAt: progress.createdAt,
            updatedAt: progress.updatedAt,
            user: user,
            product: product,
          );
        }),
      );

      return enrichedProgresses;
    } catch (e) {
      rethrow;
    }
  }
}
