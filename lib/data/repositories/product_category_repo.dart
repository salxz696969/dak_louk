import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ProductCategoryRepository extends BaseRepository<ProductCategoryModel> {
  @override
  String get tableName => Tables.productCategories.tableName;

  @override
  ProductCategoryModel fromMap(Map<String, dynamic> map) {
    return ProductCategoryModel(
      id: map[Tables.productCategories.cols.id] as int,
      name: map[Tables.productCategories.cols.name] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(ProductCategoryModel model) {
    return {
      Tables.productCategories.cols.id: model.id,
      Tables.productCategories.cols.name: model.name,
    };
  }
}
