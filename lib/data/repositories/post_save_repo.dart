import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/tables/tables.dart';

class PostSaveRepository extends BaseRepository<PostSaveModel> {
  @override
  String get tableName => Tables.postSaves.tableName;

  @override
  PostSaveModel fromMap(Map<String, dynamic> map) {
    return PostSaveModel(
      id: map[Tables.postSaves.cols.id] as int,
      userId: map[Tables.postSaves.cols.userId] as int,
      postId: map[Tables.postSaves.cols.postId] as int,
      createdAt: DateTime.parse(map[Tables.postSaves.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.postSaves.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(PostSaveModel model) {
    return {
      Tables.postSaves.cols.id: model.id,
      Tables.postSaves.cols.userId: model.userId,
      Tables.postSaves.cols.postId: model.postId,
      Tables.postSaves.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.postSaves.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
