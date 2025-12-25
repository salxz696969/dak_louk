import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/product_dao.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/cart_model.dart';

class CartDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertCart(CartModel cart) async {
    try {
      final db = await _appDatabase.database;
      final map = cart.toMap();
      map.remove('id');
      return await db.insert('carts', map);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CartModel>> getCartsByUserId(int userId) async {
    try {
      final db = await _appDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'carts',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      List<CartModel> carts = [];
      for (var map in maps) {
        ProductDao productDao = ProductDao();
        final product = await productDao.getProductById(
          map['product_id'] as int,
        );

        UserDao userDao = UserDao();
        final user = await userDao.getUserById(map['user_id'] as int);
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
        'carts',
        cart.toMap(),
        where: 'id = ?',
        whereArgs: [cart.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteCart(int id) async {
    try {
      final db = await _appDatabase.database;
      return await db.delete('carts', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }
}
