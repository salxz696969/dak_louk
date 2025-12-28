import 'package:dak_louk/db/repository/repository_base.dart';
import 'package:dak_louk/models/user_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class UserDao extends BaseRepository<UserModel> {
  @override
  String get tableName => 'users';

  @override
  UserModel fromMap(Map<String, dynamic> user) {
    return UserModel(
      // didn't use string in bracket because we want to make sure it matches the schema as well
      id: user[Tables.users.cols.id] as int,
      username: user[Tables.users.cols.username] as String,
      passwordHash: user[Tables.users.cols.passwordHash] as String,
      profileImageUrl: user[Tables.users.cols.profileImageUrl] as String,
      rating: user[Tables.users.cols.rating] as double,
      role: user[Tables.users.cols.role] as String,
      bio: user[Tables.users.cols.bio] as String,
      createdAt: DateTime.parse(user[Tables.users.cols.createdAt] as String),
      updatedAt: DateTime.parse(user[Tables.users.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(UserModel user) {
    return {
      // didn't use string keys because we want to make sure it matches the schema as well as avoid typos
      Tables.users.cols.id: user.id,
      Tables.users.cols.username: user.username,
      Tables.users.cols.passwordHash: user.passwordHash,
      Tables.users.cols.profileImageUrl: user.profileImageUrl,
      Tables.users.cols.rating: user.rating,
      Tables.users.cols.role: user.role,
      Tables.users.cols.bio: user.bio,
      Tables.users.cols.createdAt: user.createdAt,
      Tables.users.cols.updatedAt: user.updatedAt,
    };
  }

  // Additional custom methods -------------------------------

  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final statement = Clauses.where.eq(Tables.users.cols.username, username);
      final result = await queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
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
      final statement = Clauses.where.eq(Tables.users.cols.role, role);
      final orderByStmt = Clauses.orderBy.desc(Tables.users.cols.createdAt);
      final result = await queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: orderByStmt.clause,
      );
      return result.map((user) => fromMap(user)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getTopRatedUsers({int limit = 10}) async {
    try {
      final statement = Clauses.orderBy.desc(Tables.users.cols.rating);
      final result = await queryThisTable(
        where: statement.clause,
        limit: limit,
      );
      return result.map((user) => fromMap(user)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
