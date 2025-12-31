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
  static const String merchantIdCol = 'merchant_id';
  static const String nameCol = 'name';
  static const String descriptionCol = 'description';
  static const String priceCol = 'price';
  static const String quantityCol = 'quantity';

  String get merchantId => merchantIdCol;
  String get name => nameCol;
  String get description => descriptionCol;
  String get price => priceCol;
  String get quantity => quantityCol;
}
