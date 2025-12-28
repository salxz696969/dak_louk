import 'package:dak_louk/db/repositories/repository_base.dart';
import 'package:dak_louk/db/repositories/product_dao.dart';
import 'package:dak_louk/db/repositories/user_dao.dart';
import 'package:dak_louk/models/product_progress_model.dart';
import 'package:dak_louk/models/progress_status_enum.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class ProductProgressDao extends BaseRepository<ProductProgressModel> {
  @override
  String get tableName => Tables.productProgress.tableName;

  @override
  ProductProgressModel fromMap(Map<String, dynamic> map) {
    return ProductProgressModel(
      id: map[Tables.productProgress.cols.id] as int,
      userId: map[Tables.productProgress.cols.userId] as int,
      productId: map[Tables.productProgress.cols.productId] as int,
      status: ProgressStatus.values.firstWhere(
        (e) =>
            e.toString() ==
            'ProgressStatus.${map[Tables.productProgress.cols.status]}',
      ),
      createdAt: DateTime.parse(
        map[Tables.productProgress.cols.createdAt] as String,
      ),
      updatedAt: DateTime.parse(
        map[Tables.productProgress.cols.updatedAt] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(ProductProgressModel model) {
    return {
      Tables.productProgress.cols.id: model.id,
      Tables.productProgress.cols.userId: model.userId,
      Tables.productProgress.cols.productId: model.productId,
      Tables.productProgress.cols.status: model.status
          .toString()
          .split('.')
          .last,
      Tables.productProgress.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.productProgress.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }

  Future<List<ProductProgressModel>> getProductProgressesByUserId(
    int userId,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.productProgress.cols.userId,
        userId,
      );
      final progresses = await queryThisTable(
        where: statement.clause,
        args: statement.args,
      );

      if (progresses.isNotEmpty) {
        ProductDao productDao = ProductDao();
        UserDao userDao = UserDao();
        for (var progress in progresses) {
          final product = await productDao.getById(progress.productId);
          final user = await userDao.getById(progress.userId);
          progresses.add(
            ProductProgressModel(
              id: progress.id,
              userId: progress.userId,
              productId: progress.productId,
              status: progress.status,
              createdAt: progress.createdAt,
              updatedAt: progress.updatedAt,
            ),
          );
        }
      }
      return progresses;
    } catch (e) {
      rethrow;
    }
  }
}
