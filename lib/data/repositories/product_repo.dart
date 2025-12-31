import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/domain/models/index.dart';

class ProductRepository extends BaseRepository<ProductModel> {
  @override
  String get tableName => Tables.products.tableName;

  @override
  ProductModel fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map[Tables.products.cols.id] as int,
      merchantId: map[Tables.products.cols.merchantId] as int,
      name: map[Tables.products.cols.name] as String,
      description: map[Tables.products.cols.description] as String,
      price: (map[Tables.products.cols.price] as num).toDouble(),
      quantity: map[Tables.products.cols.quantity] as int,
      createdAt: DateTime.parse(map[Tables.products.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.products.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(ProductModel model) {
    return {
      Tables.products.cols.id: model.id,
      Tables.products.cols.merchantId: model.merchantId,
      Tables.products.cols.name: model.name,
      Tables.products.cols.description: model.description,
      Tables.products.cols.price: model.price,
      Tables.products.cols.quantity: model.quantity,
      Tables.products.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.products.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
