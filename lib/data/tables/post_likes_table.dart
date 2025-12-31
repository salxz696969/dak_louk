import 'package:dak_louk/data/tables/tables.dart';

class PostLikesTable implements DbTable<PostLikesCols> {
  const PostLikesTable();
  @override
  String get tableName => 'post_likes';
  @override
  PostLikesCols get cols => PostLikesCols();
}

// Note: Post likes table only has created_at, not updated_at
class PostLikesCols extends BaseCols {
  const PostLikesCols();
  static const String userIdCol = 'user_id';
  static const String postIdCol = 'post_id';

  String get userId => userIdCol;
  String get postId => postIdCol;
}
