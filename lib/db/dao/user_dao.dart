import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/models/user_model.dart';

class UserDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertUser(UserModel user) async {
    try {
      final db = await _appDatabase.database;
      final map = user.toMap();
      map.remove('id');
      return await db.insert('users', map);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUserById(int id) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
      if (result.isNotEmpty) {
        return UserModel.fromMap(result.first);
      }
      throw Exception('User not found');
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateUser(UserModel user) async {
    try {
      final db = await _appDatabase.database;
      return await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteUser(int id) async {
    try {
      final db = await _appDatabase.database;
      return await db.delete('users', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }
}
