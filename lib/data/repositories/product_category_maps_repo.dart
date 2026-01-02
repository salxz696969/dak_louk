import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/domain/models/models.dart';

class ProductCategoryMapsRepository
    extends BaseRepository<ProductCategoryMapModel> {
  @override
  String get tableName => Tables.productCategoryMaps.tableName;

  @override
  ProductCategoryMapModel fromMap(Map<String, dynamic> map) {
    return ProductCategoryMapModel(
      id: map[Tables.productCategoryMaps.cols.id] as int,
      productId: map[Tables.productCategoryMaps.cols.productId] as int,
      categoryId: map[Tables.productCategoryMaps.cols.categoryId] as int,
    );
  }

  @override
  Map<String, dynamic> toMap(ProductCategoryMapModel model) {
    return {
      Tables.productCategoryMaps.cols.id: model.id,
      Tables.productCategoryMaps.cols.productId: model.productId,
      Tables.productCategoryMaps.cols.categoryId: model.categoryId,
    };
  }
}
