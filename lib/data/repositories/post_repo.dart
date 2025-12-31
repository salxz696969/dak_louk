import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/tables/tables.dart';

class PostRepository extends BaseRepository<PostModel> {
  @override
  String get tableName => Tables.posts.tableName;

  @override
  PostModel fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map[Tables.posts.cols.id] as int,
      merchantId: map[Tables.posts.cols.merchantId] as int,
      caption: map[Tables.posts.cols.caption] as String,
      createdAt: DateTime.parse(map[Tables.posts.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.posts.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(PostModel model) {
    return {
      Tables.posts.cols.id: model.id,
      Tables.posts.cols.merchantId: model.merchantId,
      Tables.posts.cols.caption: model.caption,
      Tables.posts.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.posts.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
