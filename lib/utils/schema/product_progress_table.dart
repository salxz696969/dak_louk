import 'package:dak_louk/utils/schema/tables.dart';

class ProductProgressTable implements DbTable<ProductProgressCols> {
  const ProductProgressTable();
  @override
  String get tableName => 'product_progress';
  @override
  ProductProgressCols get cols => ProductProgressCols();
}

class ProductProgressCols extends BaseCols {
  const ProductProgressCols();
  static const String userIdCol = 'user_id';
  static const String productIdCol = 'product_id';
  static const String statusCol = 'status';

  String get userId => userIdCol;
  String get productId => productIdCol;
  String get status => statusCol;
}
