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
  static const String emailCol = 'email';
  static const String passwordHashCol = 'password_hash';
  static const String phoneCol = 'phone';
  static const String addressCol = 'address';
  static const String notesCol = 'notes';
  static const String profileImageUrlCol = 'profile_image_url';
  static const String bioCol = 'bio';

  String get username => usernameCol;
  String get email => emailCol;
  String get passwordHash => passwordHashCol;
  String get phone => phoneCol;
  String get address => addressCol;
  String get notes => notesCol;
  String get profileImageUrl => profileImageUrlCol;
  String get bio => bioCol;
}
