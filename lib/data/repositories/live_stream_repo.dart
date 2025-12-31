import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/tables/tables.dart';

class LiveStreamRepository extends BaseRepository<LiveStreamModel> {
  @override
  String get tableName => Tables.liveStreams.tableName;

  @override
  LiveStreamModel fromMap(Map<String, dynamic> map) {
    return LiveStreamModel(
      id: map[Tables.liveStreams.cols.id] as int,
      streamUrl: map[Tables.liveStreams.cols.streamUrl] as String,
      merchantId: map[Tables.liveStreams.cols.merchantId] as int,
      title: map[Tables.liveStreams.cols.title] as String,
      thumbnailUrl: map[Tables.liveStreams.cols.thumbnailUrl] as String,
      viewCount: map[Tables.liveStreams.cols.viewCount] as int,
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
      Tables.liveStreams.cols.streamUrl: model.streamUrl,
      Tables.liveStreams.cols.merchantId: model.merchantId,
      Tables.liveStreams.cols.title: model.title,
      Tables.liveStreams.cols.thumbnailUrl: model.thumbnailUrl,
      Tables.liveStreams.cols.viewCount: model.viewCount,
      Tables.liveStreams.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.liveStreams.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
