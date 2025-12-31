import 'package:dak_louk/data/tables/tables.dart';

class UsersTable implements DbTable<UsersCols> {
  const UsersTable();
  @override
  String get tableName => 'users';
  @override
  UsersCols get cols => UsersCols();
}

class UsersCols extends BaseCols {
  const UsersCols();
  static const String usernameCol = 'username';
  static const String passwordHashCol = 'password_hash';
  static const String profileImageUrlCol = 'profile_image_url';
  static const String ratingCol = 'rating';
  static const String bioCol = 'bio';
  static const String roleCol = 'role';

  String get username => usernameCol;
  String get passwordHash => passwordHashCol;
  String get profileImageUrl => profileImageUrlCol;
  String get rating => ratingCol;
  String get bio => bioCol;
  String get role => roleCol;
}
