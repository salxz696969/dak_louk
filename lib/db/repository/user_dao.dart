import 'package:dak_louk/db/repository/repository_base.dart';
import 'package:dak_louk/models/user_model.dart';

class UserDao extends BaseRepositoryImpl<UserModel> {
  @override
  String get tableName => 'users';

  @override
  UserModel fromMap(Map<String, dynamic> map) {
    return UserModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(UserModel model) {
    return model.toMap();
  }

  // Keep existing method names for backward compatibility
  Future<int> insertUser(UserModel user) => insert(user);
  Future<UserModel> getUserById(int id) => getById(id);
  Future<int> updateUser(UserModel user) => update(user);
  Future<int> deleteUser(int id) => delete(id);

  // Additional custom methods specific to UserDao
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final result = await query(where: 'username = ?', whereArgs: [username]);
      if (result.isNotEmpty) {
        return fromMap(result.first);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final result = await query(
        where: 'role = ?',
        whereArgs: [role],
        orderBy: 'created_at DESC',
      );
      return result.map((map) => fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getTopRatedUsers({int limit = 10}) async {
    try {
      final result = await query(orderBy: 'rating DESC', limit: limit);
      return result.map((map) => fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
