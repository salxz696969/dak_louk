import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ProductMediaRepository extends BaseRepository<ProductMediaModel> {
  @override
  String get tableName => Tables.productMedias.tableName;

  @override
  ProductMediaModel fromMap(Map<String, dynamic> map) {
    return ProductMediaModel(
      id: map[Tables.productMedias.cols.id] as int,
      productId: map[Tables.productMedias.cols.productId] as int,
      url: map[Tables.productMedias.cols.url] as String,
      mediaType: map[Tables.productMedias.cols.mediaType] as String?,
      createdAt: DateTime.parse(map[Tables.productMedias.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.productMedias.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(ProductMediaModel model) {
    return {
      Tables.productMedias.cols.id: model.id,
      Tables.productMedias.cols.productId: model.productId,
      Tables.productMedias.cols.url: model.url,
      Tables.productMedias.cols.mediaType: model.mediaType,
      Tables.productMedias.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.productMedias.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
