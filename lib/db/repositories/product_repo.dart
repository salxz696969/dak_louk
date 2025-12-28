import 'package:dak_louk/db/repositories/base_repo.dart';
import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class ProductRepository extends BaseRepository<ProductModel> {
  @override
  String get tableName => Tables.products.tableName;

  @override
  ProductModel fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map[Tables.products.cols.id] as int,
      userId: map[Tables.products.cols.userId],
      title: map[Tables.products.cols.title],
      description: map[Tables.products.cols.description],
      category: map[Tables.products.cols.category],
      price: map[Tables.products.cols.price],
      quantity: map[Tables.products.cols.quantity],
      createdAt: map[Tables.products.cols.createdAt],
      updatedAt: map[Tables.products.cols.updatedAt],
      image: map[Tables.products.cols.image],
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
      Tables.products.cols.createdAt: model.createdAt,
      Tables.products.cols.updatedAt: model.updatedAt,
      Tables.products.cols.image: model.image,
    };
  }
}
