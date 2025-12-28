import 'package:dak_louk/db/repositories/repository_base.dart';
import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class ProductDao extends BaseRepository<ProductModel> {
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
      liveStreamId: map[Tables.products.cols.liveStreamId],
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
      Tables.products.cols.liveStreamId: model.liveStreamId,
    };
  }

  // Additional custom methods using queryThisTable
  Future<List<ProductModel>> getAllProductsByLiveStreamId(
    int liveStreamId,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.products.cols.liveStreamId,
        liveStreamId,
      );
      final result = await queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
      if (result.isNotEmpty) {
        return result;
      }
      throw Exception('No Products found');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final statement = Clauses.where.eq(
        Tables.products.cols.category,
        category,
      );
      return await queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByUserId(int userId) async {
    try {
      final statement = Clauses.where.eq(Tables.products.cols.userId, userId);
      return await queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }
}
