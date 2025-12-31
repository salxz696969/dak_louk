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
  static const String businessNameCol = 'business_name';
  static const String businessDescriptionCol = 'business_description';

  String get userId => userIdCol;
  String get rating => ratingCol;
  String get businessName => businessNameCol;
  String get businessDescription => businessDescriptionCol;
}
