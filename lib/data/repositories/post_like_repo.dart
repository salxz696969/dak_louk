import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/index.dart';
import 'package:dak_louk/data/tables/tables.dart';

class PostLikeRepository extends BaseRepository<PostLikeModel> {
  @override
  String get tableName => Tables.postLikes.tableName;

  @override
  PostLikeModel fromMap(Map<String, dynamic> map) {
    return PostLikeModel(
      id: map[Tables.postLikes.cols.id] as int,
      userId: map[Tables.postLikes.cols.userId] as int,
      postId: map[Tables.postLikes.cols.postId] as int,
      createdAt: DateTime.parse(map[Tables.postLikes.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.postLikes.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(PostLikeModel model) {
    return {
      Tables.postLikes.cols.id: model.id,
      Tables.postLikes.cols.userId: model.userId,
      Tables.postLikes.cols.postId: model.postId,
      Tables.postLikes.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.postLikes.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
