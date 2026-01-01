import 'package:dak_louk/data/tables/tables.dart';

class MerchantsTable implements DbTable<MerchantsCols> {
  const MerchantsTable();
  @override
  String get tableName => 'merchants';
  @override
  MerchantsCols get cols => MerchantsCols();
}

class MerchantsCols extends BaseCols {
  const MerchantsCols();
  static const String userIdCol = 'user_id';
  static const String ratingCol = 'rating';
  static const String usernameCol = 'username';
  static const String emailCol = 'email';
  static const String passwordHashCol = 'password_hash';

  String get userId => userIdCol;
  String get rating => ratingCol;
  String get username => usernameCol;
  String get email => emailCol;
  String get passwordHash => passwordHashCol;
}
