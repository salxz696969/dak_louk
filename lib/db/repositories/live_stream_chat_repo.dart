import 'package:dak_louk/db/repositories/base_repo.dart';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class LiveStreamChatRepository extends BaseRepository<LiveStreamChatModel> {
  @override
  String get tableName => Tables.liveStreamChats.tableName;

  @override
  LiveStreamChatModel fromMap(Map<String, dynamic> map) {
    return LiveStreamChatModel(
      id: map[Tables.liveStreamChats.cols.id] as int,
      liveStreamId: map[Tables.liveStreamChats.cols.liveStreamId] as int,
      userId: map[Tables.liveStreamChats.cols.userId] as int,
      text: map[Tables.liveStreamChats.cols.text] as String,
      createdAt: DateTime.parse(
        map[Tables.liveStreamChats.cols.createdAt] as String,
      ),
      updatedAt: DateTime.parse(
        map[Tables.liveStreamChats.cols.updatedAt] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(LiveStreamChatModel model) {
    return {
      Tables.liveStreamChats.cols.id: model.id,
      Tables.liveStreamChats.cols.liveStreamId: model.liveStreamId,
      Tables.liveStreamChats.cols.userId: model.userId,
      Tables.liveStreamChats.cols.text: model.text,
      Tables.liveStreamChats.cols.createdAt: model.createdAt,
      Tables.liveStreamChats.cols.updatedAt: model.updatedAt,
    };
  }
}
