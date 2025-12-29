import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/live_stream_chat_model.dart';

class LiveStreamChatDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertLiveStreamChat(LiveStreamChatModel liveStreamChat) async {
    try {
      final db = await _appDatabase.database;
      final map = liveStreamChat.toMap();
      map.remove('id');
      return await db.insert('live_stream_chats', map);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStreamChatModel>> getAllLiveStreamChatByLiveStreamId(
    int id,
  ) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'live_stream_chats',
        where: 'live_stream_id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        final UserDao userDao = UserDao();
        final List<LiveStreamChatModel> liveStreamChats = [];
        for (var map in result) {
          final user = await userDao.getUserById(map['user_id'] as int);
          liveStreamChats.add(LiveStreamChatModel.fromMap(map, user));
        }
        return liveStreamChats;
      }
      throw Exception('LiveStreamChat not found');
    } catch (e) {
      rethrow;
    }
  }
}
