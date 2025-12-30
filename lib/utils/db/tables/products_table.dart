import 'package:dak_louk/utils/db/tables/tables.dart';

class ProductsTable implements DbTable<ProductsCols> {
  const ProductsTable();
  @override
  String get tableName => 'products';
  @override
  ProductsCols get cols => ProductsCols();
}

class ProductsCols extends BaseCols {
  const ProductsCols();
  static const String userIdCol = 'user_id';
  static const String titleCol = 'title';
  static const String descriptionCol = 'description';
  static const String categoryCol = 'category';
  static const String priceCol = 'price';
  static const String quantityCol = 'quantity';
  static const String liveStreamIdCol = 'live_stream_id';
  static const String imageCol = 'image_url';

  String get userId => userIdCol;
  String get title => titleCol;
  String get description => descriptionCol;
  String get category => categoryCol;
  String get price => priceCol;
  String get quantity => quantityCol;
  String get liveStreamId => liveStreamIdCol;
  String get image => imageCol;
}
