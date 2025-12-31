import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/data/tables/tables.dart';

class PostRepository extends BaseRepository<PostModel> {
  @override
  String get tableName => Tables.posts.tableName;

  @override
  PostModel fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map[Tables.posts.cols.id] as int,
      userId: map[Tables.posts.cols.userId] as int,
      title: map[Tables.posts.cols.title] as String,
      productId: map[Tables.posts.cols.productId] as int,
      createdAt: DateTime.parse(map[Tables.posts.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.posts.cols.updatedAt] as String),
      product: null,
      user: null,
      images: null,
    );
  }

  @override
  Map<String, dynamic> toMap(PostModel model) {
    return {
      Tables.posts.cols.id: model.id,
      Tables.posts.cols.userId: model.userId,
      Tables.posts.cols.title: model.title,
      Tables.posts.cols.productId: model.productId,
      Tables.posts.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.posts.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
