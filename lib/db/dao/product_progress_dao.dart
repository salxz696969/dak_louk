import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/product_dao.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/product_progress_model.dart';

class ProductProgressDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertProductProgress(ProductProgressModel progress) async {
    try {
      final db = await _appDatabase.database;
      final map = progress.toMap();
      map.remove('id');
      return await db.insert('product_progress', map);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductProgressModel>> getProductProgressesByUserId(
    int userId,
  ) async {
    try {
      final db = await _appDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'product_progress',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (maps.isNotEmpty) {
        ProductDao productDao = ProductDao();
        UserDao userDao = UserDao();
        List<ProductProgressModel> progresses = [];
        for (var map in maps) {
          final product = await productDao.getProductById(
            map['product_id'] as int,
          );
          final user = await userDao.getUserById(map['user_id'] as int);
          progresses.add(ProductProgressModel.fromMap(map, user, product));
        }
        return progresses;
      }
      throw Exception('ProductProgress not found');
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateProductProgress(ProductProgressModel progress) async {
    try {
      final db = await _appDatabase.database;
      return await db.update(
        'product_progress',
        progress.toMap(),
        where: 'id = ?',
        whereArgs: [progress.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteProductProgress(int id) async {
    try {
      final db = await _appDatabase.database;
      return await db.delete(
        'product_progress',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }
}
