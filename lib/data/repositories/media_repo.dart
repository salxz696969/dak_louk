import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/data/tables/tables.dart';

class MediaRepository extends BaseRepository<MediaModel> {
  MediaRepository();
  @override
  String get tableName => Tables.productMedias.tableName;
  @override
  MediaModel fromMap(Map<String, dynamic> map) {
    return MediaModel(
      id: map[Tables.productMedias.cols.id] as int,
      url: map[Tables.productMedias.cols.url] as String,
      postId: map[Tables.productMedias.cols.postId] as int,
      createdAt: DateTime.parse(map[Tables.productMedias.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.productMedias.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(MediaModel model) {
    return {
      Tables.productMedias.cols.id: model.id,
      Tables.productMedias.cols.url: model.url,
      Tables.productMedias.cols.postId: model.postId,
      Tables.productMedias.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.productMedias.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
