import 'package:dak_louk/data/tables/tables.dart';

class ProductCategoryMapsTable implements DbTable<ProductCategoryMapsCols> {
  const ProductCategoryMapsTable();
  @override
  String get tableName => 'product_category_maps';
  @override
  ProductCategoryMapsCols get cols => ProductCategoryMapsCols();
}

class ProductCategoryMapsCols extends BaseCols {
  const ProductCategoryMapsCols();
  static const String productIdCol = 'product_id';
  static const String categoryIdCol = 'category_id';

  String get productId => productIdCol;
  String get categoryId => categoryIdCol;
}
