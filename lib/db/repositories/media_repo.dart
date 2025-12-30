import 'package:dak_louk/db/repositories/base_repo.dart';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class MediaRepository extends BaseRepository<MediaModel> {
  MediaRepository();
  @override
  String get tableName => Tables.medias.tableName;
  @override
  MediaModel fromMap(Map<String, dynamic> map) {
    return MediaModel(
      id: map[Tables.medias.cols.id] as int,
      url: map[Tables.medias.cols.url] as String,
      postId: map[Tables.medias.cols.postId] as int,
      createdAt: DateTime.parse(map[Tables.medias.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.medias.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(MediaModel model) {
    return {
      Tables.medias.cols.id: model.id,
      Tables.medias.cols.url: model.url,
      Tables.medias.cols.postId: model.postId,
      Tables.medias.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.medias.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
