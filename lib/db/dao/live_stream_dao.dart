import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/live_stream_model.dart';

class LiveStreamDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertLiveStream(LiveStreamModel liveStream) async {
    try {
      final db = await _appDatabase.database;
      final map = liveStream.toMap();
      map.remove('id');
      return await db.insert('live_streams', map);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStreamModel>> getAllLiveStreams(int limit) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query('live_streams', limit: limit);
      if (result.isNotEmpty) {
        final List<LiveStreamModel> liveStreams = [];
        final UserDao userDao = UserDao();
        for (var map in result) {
          final user = await userDao.getUserById(map['user_id'] as int);
          liveStreams.add(LiveStreamModel.fromMap(map, user, null, null));
        }
        return liveStreams;
      }
      throw Exception('No LiveStreams found');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStreamModel>> getAllLiveStreamsByUserId(
    int userId,
    int limit,
  ) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'live_streams',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: limit,
      );
      if (result.isNotEmpty) {
        final List<LiveStreamModel> liveStreams = [];
        final UserDao userDao = UserDao();
        for (var map in result) {
          final user = await userDao.getUserById(map['user_id'] as int);
          liveStreams.add(LiveStreamModel.fromMap(map, user, null, null));
        }
        return liveStreams;
      }
      throw Exception('No LiveStreams found');
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateLiveStream(LiveStreamModel liveStream) async {
    try {
      final db = await _appDatabase.database;
      return await db.update(
        'live_streams',
        liveStream.toMap(),
        where: 'id = ?',
        whereArgs: [liveStream.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteLiveStream(int id) async {
    try {
      final db = await _appDatabase.database;
      return await db.delete('live_streams', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }
}
