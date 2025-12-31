import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/index.dart';
import 'package:dak_louk/data/tables/tables.dart';

class UserRepository extends BaseRepository<UserModel> {
  @override
  String get tableName => Tables.users.tableName;

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
}
