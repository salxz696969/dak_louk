import 'package:dak_louk/data/tables/tables.dart';

class ProductCategoriesTable implements DbTable<ProductCategoriesCols> {
  const ProductCategoriesTable();
  @override
  String get tableName => 'product_categories';
  @override
  ProductCategoriesCols get cols => ProductCategoriesCols();
}

class ProductCategoriesCols extends BaseCols {
  const ProductCategoriesCols();
  static const String nameCol = 'name';

  String get name => nameCol;
}
