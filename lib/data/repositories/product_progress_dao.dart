import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ProductProgressRepository extends BaseRepository<ProductProgressModel> {
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
}
