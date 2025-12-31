import 'package:dak_louk/data/tables/tables.dart';

class ProductMediasTable implements DbTable<ProductMediasCols> {
  const ProductMediasTable();
  @override
  String get tableName => 'product_medias';
  @override
  ProductMediasCols get cols => ProductMediasCols();
}

class ProductMediasCols extends BaseCols {
  const ProductMediasCols();
  static const String productIdCol = 'product_id';
  static const String urlCol = 'url';
  static const String mediaTypeCol = 'media_type';

  String get productId => productIdCol;
  String get url => urlCol;
  String get mediaType => mediaTypeCol;
}
