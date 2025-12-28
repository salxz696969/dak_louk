import 'package:dak_louk/utils/db/tables/tables.dart';

class PostsTable implements DbTable<PostsCols> {
  const PostsTable();
  @override
  String get tableName => 'posts';
  @override
  PostsCols get cols => PostsCols();
}

class PostsCols extends BaseCols {
  const PostsCols();
  static const String userIdCol = 'user_id';
  static const String titleCol = 'title';
  static const String productIdCol = 'product_id';
  static const String categoryCol = 'category';

  String get userId => userIdCol;
  String get title => titleCol;
  String get productId => productIdCol;
  String get category => categoryCol;
}
