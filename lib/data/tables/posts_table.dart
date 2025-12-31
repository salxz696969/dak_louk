import 'package:dak_louk/data/tables/tables.dart';

class PostsTable implements DbTable<PostsCols> {
  const PostsTable();
  @override
  String get tableName => 'posts';
  @override
  PostsCols get cols => PostsCols();
}

class PostsCols extends BaseCols {
  const PostsCols();
  static const String merchantIdCol = 'merchant_id';
  static const String captionCol = 'caption';

  String get merchantId => merchantIdCol;
  String get caption => captionCol;
}
