import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/live_stream_repo.dart';
import 'package:dak_louk/data/repositories/live_stream_chat_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class LiveStreamService {
  late final currentUserId;
  final LiveStreamRepository _liveStreamRepository = LiveStreamRepository();
  final LiveStreamChatRepository _liveStreamChatRepository =
      LiveStreamChatRepository();

  LiveStreamService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  // Business logic methods migrated from LiveStreamRepository
  Future<List<LiveStreamVM>> getAllLiveStreamsByUserId(
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
            return LiveStreamVM.fromRaw(liveStream);
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
  Future<List<LiveStreamVM>> getAllLiveStreamsWithProducts(int limit) async {
    try {
      final liveStreams = await _liveStreamRepository.queryThisTable(
        limit: limit,
      );

      if (liveStreams.isNotEmpty) {
        // Populate relations like in the original DAO
        final enrichedLiveStreams = await Future.wait(
          liveStreams.map((liveStream) async {
            return LiveStreamVM.fromRaw(liveStream);
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
  Future<LiveStreamVM?> createLiveStream(CreateLiveStreamDTO dto) async {
    try {
      final liveStreamModel = LiveStreamModel(
        id: 0,
        merchantId: currentUserId,
        title: dto.title,
        streamUrl: dto.streamUrl,
        thumbnailUrl: dto.thumbnailUrl,
        viewCount: dto.viewCount,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await _liveStreamRepository.insert(liveStreamModel);
      final newLiveStream = await _liveStreamRepository.getById(id);
      if (newLiveStream != null) {
        return LiveStreamVM.fromRaw(newLiveStream);
      }
      throw AppError(
        type: ErrorType.NOT_FOUND,
        message: 'Live stream not found',
      );
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create live stream',
      );
    }
  }

  Future<LiveStreamVM?> getLiveStreamById(int id) async {
    try {
      final newLiveStream = await _liveStreamRepository.getById(id);
      if (newLiveStream != null) {
        return LiveStreamVM.fromRaw(newLiveStream);
      }
      throw AppError(
        type: ErrorType.NOT_FOUND,
        message: 'Live stream not found',
      );
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get live stream',
      );
    }
  }

  Future<LiveStreamVM?> updateLiveStream(
    int id,
    UpdateLiveStreamDTO dto,
  ) async {
    try {
      final liveStream = await _liveStreamRepository.getById(id);
      if (liveStream == null) {
        throw AppError(
          type: ErrorType.NOT_FOUND,
          message: 'Live stream not found',
        );
      }
      if (liveStream.merchantId != currentUserId) {
        throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
      }
      final liveStreamModel = LiveStreamModel(
        id: id,
        merchantId: liveStream.merchantId,
        title: dto.title ?? liveStream.title,
        streamUrl: dto.streamUrl ?? liveStream.streamUrl,
        thumbnailUrl: dto.thumbnailUrl ?? liveStream.thumbnailUrl,
        viewCount: dto.viewCount ?? liveStream.viewCount,
        createdAt: liveStream.createdAt,
        updatedAt: DateTime.now(),
      );
      await _liveStreamRepository.update(liveStreamModel);
      final newLiveStream = await _liveStreamRepository.getById(id);
      if (newLiveStream != null) {
        return LiveStreamVM.fromRaw(newLiveStream);
      }
      throw AppError(
        type: ErrorType.NOT_FOUND,
        message: 'Live stream not found',
      );
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to update live stream',
      );
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
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to delete live stream',
      );
    }
  }
}
