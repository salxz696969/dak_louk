import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/repository/product_dao.dart';
import 'package:dak_louk/db/repository/user_dao.dart';
import 'package:dak_louk/models/cart_model.dart';
import 'package:dak_louk/utils/orm.dart';
import 'package:dak_louk/utils/schema/tables.dart';

class CartDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertCart(CartModel cart) async {
    try {
      final db = await _appDatabase.database;
      final map = cart.toMap();
      map.remove(Tables.id);
      return await db.insert(Tables.carts.tableName, map);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CartModel>> getCartsByUserId(int userId) async {
    try {
      final db = await _appDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        Tables.carts.tableName,
        where: Clauses.where.eq(Tables.carts.cols.userId, userId).clause,
        whereArgs: [userId],
      );

      List<CartModel> carts = [];
      for (var map in maps) {
        ProductDao productDao = ProductDao();
        final product = await productDao.getProductById(
          map[Tables.carts.cols.productId] as int,
        );

        UserDao userDao = UserDao();
        final user = await userDao.getUserById(
          map[Tables.carts.cols.userId] as int,
        );
        final seller = await userDao.getUserById(product.userId);

        carts.add(CartModel.fromMap(map, user, product, seller));
      }
      return carts;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateCart(CartModel cart) async {
    try {
      final db = await _appDatabase.database;
      return await db.update(
        Tables.carts.tableName,
        cart.toMap(),
        where: Clauses.where.eq(Tables.carts.cols.id, cart.id).clause,
        whereArgs: Clauses.where.eq(Tables.carts.cols.id, cart.id).args,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteCart(int id) async {
    try {
      final db = await _appDatabase.database;
      final statement = Clauses.where.eq(Tables.carts.cols.id, id);
      return await db.delete(
        Tables.carts.tableName,
        where: statement.clause,
        whereArgs: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }
}
