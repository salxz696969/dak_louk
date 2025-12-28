import 'package:dak_louk/db/repositories/base_repo.dart';
import 'package:dak_louk/models/live_stream_model.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class LiveStreamRepository extends BaseRepository<LiveStreamModel> {
  @override
  String get tableName => Tables.liveStreams.tableName;

  @override
  LiveStreamModel fromMap(Map<String, dynamic> map) {
    return LiveStreamModel(
      id: map[Tables.liveStreams.cols.id] as int,
      url: map[Tables.liveStreams.cols.url] as String,
      userId: map[Tables.liveStreams.cols.userId] as int,
      title: map[Tables.liveStreams.cols.title] as String,
      thumbnailUrl: map[Tables.liveStreams.cols.thumbnailUrl] as String,
      view: map[Tables.liveStreams.cols.view] as int,
      createdAt: DateTime.parse(
        map[Tables.liveStreams.cols.createdAt] as String,
      ),
      updatedAt: DateTime.parse(
        map[Tables.liveStreams.cols.updatedAt] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(LiveStreamModel model) {
    return {
      Tables.liveStreams.cols.id: model.id,
      Tables.liveStreams.cols.url: model.url,
      Tables.liveStreams.cols.userId: model.userId,
      Tables.liveStreams.cols.title: model.title,
      Tables.liveStreams.cols.thumbnailUrl: model.thumbnailUrl,
      Tables.liveStreams.cols.view: model.view,
      Tables.liveStreams.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.liveStreams.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
