import 'package:dak_louk/data/tables/tables.dart';

class PostProductsTable implements DbTable<PostProductsCols> {
  const PostProductsTable();
  @override
  String get tableName => 'post_products';
  @override
  PostProductsCols get cols => PostProductsCols();
}

class PostProductsCols extends BaseCols {
  const PostProductsCols();
  static const String postIdCol = 'post_id';
  static const String productIdCol = 'product_id';

  String get postId => postIdCol;
  String get productId => productIdCol;
}
