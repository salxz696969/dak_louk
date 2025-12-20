import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/models/product_model.dart';

class ProductDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertProduct(Product product) async {
    final db = await _appDatabase.database;
    return await db.insert('products', product.toMap());
  }

  Future<Product> getProductById(int id) async {
    final db = await _appDatabase.database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return throw Exception('Product not found');
  }

  Future<int> updateProduct(Product product) async {
    final db = await _appDatabase.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await _appDatabase.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
