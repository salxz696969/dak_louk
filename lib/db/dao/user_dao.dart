import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/models/user_model.dart';

class UserDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertUser(User user) async {
    final db = await _appDatabase.database;
    return await db.insert('users', user.toMap());
  }

  Future<User> getUserById(int id) async {
    final db = await _appDatabase.database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    throw Exception('User not found');
  }

  Future<int> updateUser(User user) async {
    final db = await _appDatabase.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await _appDatabase.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
