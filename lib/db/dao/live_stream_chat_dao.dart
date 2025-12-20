import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/live_stream_chat_model.dart';

class LiveStreamChatDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertLiveStreamChat(LiveStreamChat liveStreamChat) async {
    final db = await _appDatabase.database;
    return await db.insert('live_stream_chats', liveStreamChat.toMap());
  }

  Future<List<LiveStreamChat>> getAllLiveStreamChatByLiveStreamId(
    int id,
  ) async {
    final db = await _appDatabase.database;
    final result = await db.query(
      'live_stream_chats',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      final UserDao userDao = UserDao();
      final List<LiveStreamChat> liveStreamChats = [];
      for (var map in result) {
        final user = await userDao.getUserById(map['user_id'] as int);
        liveStreamChats.add(LiveStreamChat.fromMap(map, user));
      }
      return liveStreamChats;
    }
    throw Exception('LiveStreamChat not found');
  }
}
