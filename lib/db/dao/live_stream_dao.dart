import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/live_stream_model.dart';

class LiveStreamDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertLiveStream(LiveStream liveStream) async {
    final db = await _appDatabase.database;
    return await db.insert('live_streams', liveStream.toMap());
  }

  Future<List<LiveStream>> getAllLiveStreams() async {
    final db = await _appDatabase.database;
    final result = await db.query('live_streams', limit: 20);
    if (result.isNotEmpty) {
      final List<LiveStream> liveStreams = [];
      final UserDao userDao = UserDao();
      for (var map in result) {
        final user = await userDao.getUserById(map['user_id'] as int);
        liveStreams.add(LiveStream.fromMap(map, user, null, null));
      }
    }
    throw Exception('No LiveStreams found');
  }

  Future<int> updateLiveStream(LiveStream liveStream) async {
    final db = await _appDatabase.database;
    return await db.update(
      'live_streams',
      liveStream.toMap(),
      where: 'id = ?',
      whereArgs: [liveStream.id],
    );
  }

  Future<int> deleteLiveStream(int id) async {
    final db = await _appDatabase.database;
    return await db.delete('live_streams', where: 'id = ?', whereArgs: [id]);
  }
}
