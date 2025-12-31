import 'package:dak_louk/data/repositories/live_stream_repo.dart';
import 'package:dak_louk/data/repositories/live_stream_chat_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class LiveStreamService {
  final LiveStreamRepository _liveStreamRepository = LiveStreamRepository();
  final LiveStreamChatRepository _liveStreamChatRepository =
      LiveStreamChatRepository();

  // Business logic methods migrated from LiveStreamRepository
  Future<List<LiveStreamModel>> getAllLiveStreamsByUserId(
    int userId,
    int limit,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.liveStreams.cols.merchantId,
        userId,
      );
      final liveStreams = await _liveStreamRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        limit: limit,
      );

      if (liveStreams.isNotEmpty) {
        // Populate relations like in the original DAO
        final enrichedLiveStreams = await Future.wait(
          liveStreams.map((liveStream) async {
            return LiveStreamModel(
              id: liveStream.id,
              streamUrl: liveStream.streamUrl,
              merchantId: liveStream.merchantId,
              title: liveStream.title,
              thumbnailUrl: liveStream.thumbnailUrl,
              viewCount: liveStream.viewCount,
              createdAt: liveStream.createdAt,
              updatedAt: liveStream.updatedAt,
            );
          }),
        );

        return enrichedLiveStreams;
      }
      throw Exception('No LiveStreams found');
    } catch (e) {
      rethrow;
    }
  }

  // Future<List<LiveStreamModel>> getAllLiveStreams(int limit) async {
  //   try {
  //     final db = await _appDatabase.database;
  //     final result = await db.query('live_streams', limit: limit);
  //     if (result.isNotEmpty) {
  //       final List<LiveStreamModel> liveStreams = [];
  //       final UserDao userDao = UserDao();
  //       final PostDao postDao = PostDao();
  //       final LiveStreamChatDao liveStreamChatDao = LiveStreamChatDao();
  //       for (var map in result) {
  //         final user = await userDao.getUserById(map['user_id'] as int);
  //         final posts = await postDao.getPostsByLiveStreamId(map['id'] as int);
  //         final liveStreamChats = await liveStreamChatDao
  //             .getAllLiveStreamChatByLiveStreamId(map['id'] as int);
  //         liveStreams.add(
  //           LiveStreamModel.fromMap(map, user, posts, liveStreamChats),
  //         );
  //       }
  //       return liveStreams;
  //     }
  //     throw Exception('No LiveStreams found');
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Migrated from LiveStreamDao
  Future<List<LiveStreamModel>> getAllLiveStreamsWithProducts(int limit) async {
    try {
      final liveStreams = await _liveStreamRepository.queryThisTable(
        limit: limit,
      );

      if (liveStreams.isNotEmpty) {
        // Populate relations like in the original DAO
        final enrichedLiveStreams = await Future.wait(
          liveStreams.map((liveStream) async {
            return LiveStreamModel(
              id: liveStream.id,
              streamUrl: liveStream.streamUrl,
              merchantId: liveStream.merchantId,
              title: liveStream.title,
              thumbnailUrl: liveStream.thumbnailUrl,
              viewCount: liveStream.viewCount,
              createdAt: liveStream.createdAt,
              updatedAt: liveStream.updatedAt,
            );
          }),
        );

        return enrichedLiveStreams;
      }
      throw Exception('No LiveStreams found');
    } catch (e) {
      rethrow;
    }
  }

  // Basic CRUD operations
  Future<LiveStreamModel?> createLiveStream(LiveStreamModel liveStream) async {
    try {
      final id = await _liveStreamRepository.insert(liveStream);
      final newLiveStream = await _liveStreamRepository.getById(id);
      if (newLiveStream != null) {
        return newLiveStream;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<LiveStreamModel?> getLiveStreamById(int id) async {
    try {
      final newLiveStream = await _liveStreamRepository.getById(id);
      if (newLiveStream != null) {
        return newLiveStream;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<LiveStreamModel?> updateLiveStream(LiveStreamModel liveStream) async {
    try {
      await _liveStreamRepository.update(liveStream);
      final newLiveStream = await _liveStreamRepository.getById(liveStream.id);
      if (newLiveStream != null) {
        return newLiveStream;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteLiveStream(int liveStreamId) async {
    try {
      // Delete associated chats first
      final chatStatement = Clauses.where.eq(
        Tables.liveStreamChats.cols.liveStreamId,
        liveStreamId,
      );
      final chats = await _liveStreamChatRepository.queryThisTable(
        where: chatStatement.clause,
        args: chatStatement.args,
      );

      for (final chat in chats) {
        await _liveStreamChatRepository.delete(chat.id);
      }

      // Delete the live stream
      await _liveStreamRepository.delete(liveStreamId);
    } catch (e) {
      rethrow;
    }
  }
}
