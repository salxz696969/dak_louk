import 'package:dak_louk/utils/db/tables/tables.dart';

class PostSavesTable implements DbTable<PostSavesCols> {
  const PostSavesTable();
  @override
  String get tableName => 'post_saves';
  @override
  PostSavesCols get cols => PostSavesCols();
}

// Note: Post saves table only has created_at, not updated_at
class PostSavesCols extends BaseColsCreatedOnly {
  const PostSavesCols();
  static const String userIdCol = 'user_id';
  static const String postIdCol = 'post_id';

  String get userId => userIdCol;
  String get postId => postIdCol;
}
