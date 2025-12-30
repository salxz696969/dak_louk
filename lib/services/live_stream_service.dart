import 'package:dak_louk/db/repositories/live_stream_repo.dart';
import 'package:dak_louk/db/repositories/user_repo.dart';
import 'package:dak_louk/db/repositories/product_repo.dart';
import 'package:dak_louk/db/repositories/live_stream_chat_repo.dart';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class LiveStreamService {
  final LiveStreamRepository _liveStreamRepository = LiveStreamRepository();
  final UserRepository _userRepository = UserRepository();
  final ProductRepository _productRepository = ProductRepository();
  final LiveStreamChatRepository _liveStreamChatRepository =
      LiveStreamChatRepository();

  // Business logic methods migrated from LiveStreamRepository
  Future<List<LiveStreamModel>> getAllLiveStreamsByUserId(
    int userId,
    int limit,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.liveStreams.cols.userId,
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
            final user = await _userRepository.getById(liveStream.userId);

            // Get products associated with this live stream
            final productStatement = Clauses.where.eq(
              Tables.products.cols.liveStreamId,
              liveStream.id,
            );
            final products = await _productRepository.queryThisTable(
              where: productStatement.clause,
              args: productStatement.args,
            );

            return LiveStreamModel(
              id: liveStream.id,
              url: liveStream.url,
              userId: liveStream.userId,
              title: liveStream.title,
              thumbnailUrl: liveStream.thumbnailUrl,
              view: liveStream.view,
              createdAt: liveStream.createdAt,
              updatedAt: liveStream.updatedAt,
              user: user,
              products: products,
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

  // Migrated from LiveStreamDao
  Future<List<LiveStreamModel>> getAllLiveStreams(int limit) async {
    try {
      final liveStreams = await _liveStreamRepository.queryThisTable(
        limit: limit,
      );

      if (liveStreams.isNotEmpty) {
        // Populate relations like in the original DAO
        final enrichedLiveStreams = await Future.wait(
          liveStreams.map((liveStream) async {
            final user = await _userRepository.getById(liveStream.userId);

            // Get products associated with this live stream
            final productStatement = Clauses.where.eq(
              Tables.products.cols.liveStreamId,
              liveStream.id,
            );
            final products = await _productRepository.queryThisTable(
              where: productStatement.clause,
              args: productStatement.args,
            );

            return LiveStreamModel(
              id: liveStream.id,
              url: liveStream.url,
              userId: liveStream.userId,
              title: liveStream.title,
              thumbnailUrl: liveStream.thumbnailUrl,
              view: liveStream.view,
              createdAt: liveStream.createdAt,
              updatedAt: liveStream.updatedAt,
              user: user,
              products: products,
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

  // Additional business logic methods
  Future<List<LiveStreamModel>> getActiveLiveStreams() async {
    try {
      // Assuming active streams are those created recently
      final statement = Clauses.where.gte(
        Tables.liveStreams.cols.createdAt,
        DateTime.now().subtract(const Duration(hours: 24)).toIso8601String(),
      );
      final orderByStmt = Clauses.orderBy.desc(Tables.liveStreams.cols.view);

      return await _liveStreamRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: orderByStmt.clause,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStreamModel>> getPopularLiveStreams({int limit = 10}) async {
    try {
      final orderByStmt = Clauses.orderBy.desc(Tables.liveStreams.cols.view);
      return await _liveStreamRepository.queryThisTable(
        orderBy: orderByStmt.clause,
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStreamModel>> searchLiveStreams(String searchTerm) async {
    try {
      final statement = Clauses.like.like(
        Tables.liveStreams.cols.title,
        searchTerm,
      );
      return await _liveStreamRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<LiveStreamModel> incrementViewCount(int liveStreamId) async {
    try {
      final liveStream = await _liveStreamRepository.getById(liveStreamId);
      final updatedLiveStream = LiveStreamModel(
        id: liveStream.id,
        url: liveStream.url,
        userId: liveStream.userId,
        title: liveStream.title,
        thumbnailUrl: liveStream.thumbnailUrl,
        view: liveStream.view + 1,
        createdAt: liveStream.createdAt,
        updatedAt: DateTime.now(),
      );

      await _liveStreamRepository.update(updatedLiveStream);
      return updatedLiveStream;
    } catch (e) {
      rethrow;
    }
  }

  // Get live stream with all relations populated
  Future<LiveStreamModel> getLiveStreamWithRelations(int liveStreamId) async {
    try {
      final liveStream = await _liveStreamRepository.getById(liveStreamId);
      final user = await _userRepository.getById(liveStream.userId);

      // Get products associated with this live stream
      final productStatement = Clauses.where.eq(
        Tables.products.cols.liveStreamId,
        liveStreamId,
      );
      final products = await _productRepository.queryThisTable(
        where: productStatement.clause,
        args: productStatement.args,
      );

      // Get live stream chats
      return LiveStreamModel(
        id: liveStream.id,
        url: liveStream.url,
        userId: liveStream.userId,
        title: liveStream.title,
        thumbnailUrl: liveStream.thumbnailUrl,
        view: liveStream.view,
        createdAt: liveStream.createdAt,
        updatedAt: liveStream.updatedAt,
        user: user,
        products: products,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStreamModel>> getRecentLiveStreams({int limit = 20}) async {
    try {
      final orderByStmt = Clauses.orderBy.desc(
        Tables.liveStreams.cols.createdAt,
      );
      return await _liveStreamRepository.queryThisTable(
        orderBy: orderByStmt.clause,
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Basic CRUD operations
  Future<LiveStreamModel> createLiveStream(LiveStreamModel liveStream) async {
    try {
      final id = await _liveStreamRepository.insert(liveStream);
      return await _liveStreamRepository.getById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<LiveStreamModel> getLiveStreamById(int id) async {
    try {
      return await _liveStreamRepository.getById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<LiveStreamModel> updateLiveStream(LiveStreamModel liveStream) async {
    try {
      await _liveStreamRepository.update(liveStream);
      return await _liveStreamRepository.getById(liveStream.id);
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

  Future<List<LiveStreamModel>> getAllLiveStreamsSimple() async {
    try {
      return await _liveStreamRepository.getAll();
    } catch (e) {
      rethrow;
    }
  }
}
