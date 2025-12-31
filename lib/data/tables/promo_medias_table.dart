import 'package:dak_louk/data/tables/tables.dart';

class PromoMediasTable implements DbTable<PromoMediasCols> {
  const PromoMediasTable();
  @override
  String get tableName => 'promo_medias';
  @override
  PromoMediasCols get cols => PromoMediasCols();
}

class PromoMediasCols extends BaseCols {
  const PromoMediasCols();
  static const String postIdCol = 'post_id';
  static const String urlCol = 'url';
  static const String mediaTypeCol = 'media_type';

  String get postId => postIdCol;
  String get url => urlCol;
  String get mediaType => mediaTypeCol;
}
