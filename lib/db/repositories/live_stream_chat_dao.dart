import 'package:dak_louk/db/repositories/repository_base.dart';
import 'package:dak_louk/utils/db/app_database.dart';
import 'package:dak_louk/db/repositories/user_dao.dart';
import 'package:dak_louk/models/live_stream_chat_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class LiveStreamChatDao extends BaseRepository<LiveStreamChatModel> {
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

  Future<List<LiveStreamChatModel>> getAllLiveStreamChatByLiveStreamId(
    int id,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.liveStreamChats.cols.liveStreamId,
        id,
      );
      final result = await queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
      if (result.isNotEmpty) {
        return result;
      }
      throw Exception('LiveStreamChat not found');
    } catch (e) {
      rethrow;
    }
  }
}
