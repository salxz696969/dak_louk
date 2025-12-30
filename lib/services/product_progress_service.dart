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

  // Additional business logic methods
  Future<List<ProductProgressModel>> getProgressesByStatus(
    ProgressStatus status,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.productProgress.cols.status,
        status.toString().split('.').last,
      );
      return await _productProgressRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy
            .desc(Tables.productProgress.cols.createdAt)
            .clause,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductProgressModel>> getProgressesByProductId(
    int productId,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.productProgress.cols.productId,
        productId,
      );
      return await _productProgressRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy
            .desc(Tables.productProgress.cols.createdAt)
            .clause,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductProgressModel?> getUserProgressForProduct(
    int userId,
    int productId,
  ) async {
    try {
      final userStatement = Clauses.where.eq(
        Tables.productProgress.cols.userId,
        userId,
      );
      final productStatement = Clauses.where.eq(
        Tables.productProgress.cols.productId,
        productId,
      );
      final combinedStatement = Clauses.where.and([
        userStatement,
        productStatement,
      ]);

      final progresses = await _productProgressRepository.queryThisTable(
        where: combinedStatement.clause,
        args: combinedStatement.args,
        orderBy: Clauses.orderBy
            .desc(Tables.productProgress.cols.createdAt)
            .clause,
        limit: 1,
      );

      return progresses.isNotEmpty ? progresses.first : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductProgressModel>> getPendingOrders() async {
    try {
      return await getProgressesByStatus(ProgressStatus.waiting);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductProgressModel>> getProcessingOrders() async {
    try {
      return await getProgressesByStatus(ProgressStatus.accepted);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductProgressModel>> getShippedOrders() async {
    try {
      return await getProgressesByStatus(ProgressStatus.delivering);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductProgressModel>> getDeliveredOrders() async {
    try {
      return await getProgressesByStatus(ProgressStatus.completed);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductProgressModel>> getCancelledOrders() async {
    try {
      return await getProgressesByStatus(ProgressStatus.cancelled);
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductProgressModel?> updateOrderStatus(
    int progressId,
    ProgressStatus newStatus,
  ) async {
    try {
      final progress = await _productProgressRepository.getById(progressId);
      if (progress == null) {
        return null;
      }
      final updatedProgress = ProductProgressModel(
        id: progress.id,
        userId: progress.userId,
        productId: progress.productId,
        status: newStatus,
        createdAt: progress.createdAt,
        updatedAt: DateTime.now(),
      );

      await _productProgressRepository.update(updatedProgress);
      final newProgress = await _productProgressRepository.getById(progressId);
      if (newProgress != null) {
        return newProgress;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductProgressModel>> getOrderHistory(int userId) async {
    try {
      return await getProductProgressesByUserId(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductProgressModel>> getActiveOrders(int userId) async {
    try {
      final userStatement = Clauses.where.eq(
        Tables.productProgress.cols.userId,
        userId,
      );
      final pendingStatement = Clauses.where.eq(
        Tables.productProgress.cols.status,
        ProgressStatus.accepted.toString().split('.').last,
      );
      final processingStatement = Clauses.where.eq(
        Tables.productProgress.cols.status,
        ProgressStatus.accepted.toString().split('.').last,
      );
      final shippedStatement = Clauses.where.eq(
        Tables.productProgress.cols.status,
        ProgressStatus.delivering.toString().split('.').last,
      );

      final activeStatusStatement = Clauses.where.or([
        pendingStatement,
        processingStatement,
        shippedStatement,
      ]);

      final combinedStatement = Clauses.where.and([
        userStatement,
        activeStatusStatement,
      ]);

      return await _productProgressRepository.queryThisTable(
        where: combinedStatement.clause,
        args: combinedStatement.args,
        orderBy: Clauses.orderBy
            .desc(Tables.productProgress.cols.createdAt)
            .clause,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<ProgressStatus, int>> getOrderStatistics() async {
    try {
      final allProgresses = await _productProgressRepository.getAll();
      final statistics = <ProgressStatus, int>{};

      for (final status in ProgressStatus.values) {
        statistics[status] = allProgresses
            .where((p) => p.status == status)
            .length;
      }

      return statistics;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<ProgressStatus, int>> getUserOrderStatistics(int userId) async {
    try {
      final userProgresses = await getProductProgressesByUserId(userId);
      final statistics = <ProgressStatus, int>{};

      for (final status in ProgressStatus.values) {
        statistics[status] = userProgresses
            .where((p) => p.status == status)
            .length;
      }

      return statistics;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> canCancelOrder(int progressId) async {
    try {
      final progress = await _productProgressRepository.getById(progressId);
      if (progress == null) {
        return false;
      }
      return progress.status == ProgressStatus.waiting ||
          progress.status == ProgressStatus.accepted;
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductProgressModel?> cancelOrder(int progressId) async {
    try {
      final canCancel = await canCancelOrder(progressId);
      if (!canCancel) {
        return null;
      }

      final updatedProgress = await updateOrderStatus(
        progressId,
        ProgressStatus.cancelled,
      );
      if (updatedProgress != null) {
        return updatedProgress;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Basic CRUD operations
  Future<ProductProgressModel?> createProgress(
    ProductProgressModel progress,
  ) async {
    try {
      final id = await _productProgressRepository.insert(progress);
      final newProgress = await _productProgressRepository.getById(id);
      if (newProgress != null) {
        return newProgress;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductProgressModel?> getProgressById(int id) async {
    try {
      final newProgress = await _productProgressRepository.getById(id);
      if (newProgress != null) {
        return newProgress;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductProgressModel?> updateProgress(
    ProductProgressModel progress,
  ) async {
    try {
      await _productProgressRepository.update(progress);
      final newProgress = await _productProgressRepository.getById(progress.id);
      if (newProgress != null) {
        return newProgress;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProgress(int progressId) async {
    try {
      await _productProgressRepository.delete(progressId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductProgressModel>> getAllProgresses() async {
    try {
      return await _productProgressRepository.getAll();
    } catch (e) {
      rethrow;
    }
  }
}
