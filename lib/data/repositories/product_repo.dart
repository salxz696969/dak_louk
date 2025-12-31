import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/domain/domain.dart';

class ProductRepository extends BaseRepository<ProductModel> {
  @override
  String get tableName => Tables.products.tableName;

  @override
  ProductModel fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map[Tables.products.cols.id] as int,
      userId: map[Tables.products.cols.userId] as int,
      title: map[Tables.products.cols.title] as String,
      description: map[Tables.products.cols.description] as String,
      category: ProductCategory.values.firstWhere(
        (e) => e.name == map[Tables.products.cols.category],
        orElse: () => ProductCategory.others,
      ),
      price: (map[Tables.products.cols.price] as num).toDouble(),
      quantity: map[Tables.products.cols.quantity] as int,
      createdAt: DateTime.parse(map[Tables.products.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.products.cols.updatedAt] as String),
      image: map[Tables.products.cols.image] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(ProductModel model) {
    return {
      Tables.products.cols.id: model.id,
      Tables.products.cols.userId: model.userId,
      Tables.products.cols.title: model.title,
      Tables.products.cols.description: model.description,
      Tables.products.cols.category: model.category.name,
      Tables.products.cols.price: model.price,
      Tables.products.cols.quantity: model.quantity,
      Tables.products.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.products.cols.updatedAt: model.updatedAt.toIso8601String(),
      Tables.products.cols.image: model.image,
    };
  }
}
