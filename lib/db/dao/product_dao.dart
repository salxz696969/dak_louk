import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/models/product_model.dart';

class ProductDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertProduct(ProductModel product) async {
    try {
      final db = await _appDatabase.database;
      final map = product.toMap();
      map.remove('id');
      return await db.insert('products', map);
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductModel> getProductById(int id) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return ProductModel.fromMap(
          result.first,
          result.first['image_url'] as String,
        );
      }
      return throw Exception('Product not found');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getAllProductsByLiveStreamId(
    int liveStreamId,
  ) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'products',
        where: 'live_stream_id = ?',
        whereArgs: [liveStreamId],
      );
      if (result.isNotEmpty) {
        return result
            .map((map) => ProductModel.fromMap(map, map['image_url'] as String))
            .toList();
      }
      throw Exception('No Products found');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getAllProducts(String category, int limit) async {
    try {
      final db = await _appDatabase.database;
      List<Map<String, dynamic>> result = <Map<String, dynamic>>[];
      if (limit <= 0) {
        limit = 100;
      }
      if (category == 'all') {
        result = await db.query('products', limit: limit);
      } else {
        result = await db.query(
          'products',
          limit: limit,
          where: 'category = ?',
          whereArgs: [category],
        );
      }

      return result
          .map((map) => ProductModel.fromMap(map, map['image_url'] as String))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateProduct(ProductModel product) async {
    try {
      final db = await _appDatabase.database;
      return await db.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteProduct(int id) async {
    try {
      final db = await _appDatabase.database;
      return await db.delete('products', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }
}
