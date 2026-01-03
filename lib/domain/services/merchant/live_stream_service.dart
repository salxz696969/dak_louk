import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/live_stream_repo.dart';
import 'package:dak_louk/data/repositories/live_stream_chat_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class LiveStreamService {
  late final currentMerchantId;
  final LiveStreamRepository _liveStreamRepository = LiveStreamRepository();
  final LiveStreamChatRepository _liveStreamChatRepository =
      LiveStreamChatRepository();

  LiveStreamService() {
    if (AppSession.instance.isLoggedIn &&
        AppSession.instance.merchantId != null) {
      currentMerchantId = AppSession.instance.merchantId;
    } else {
      throw AppError(
        type: ErrorType.UNAUTHORIZED,
        message: 'Unauthorized - No merchant session',
      );
    }
  }

  Future<List<MerchantLiveStreamsVM>> getAllLiveStreams() async {
    try {
      final statement = Clauses.where.eq(
        Tables.liveStreams.cols.merchantId,
        currentMerchantId,
      );
      final liveStreams = await _liveStreamRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.liveStreams.cols.createdAt).clause,
      );
      return liveStreams
          .map((stream) => MerchantLiveStreamsVM.fromRaw(stream))
          .toList();
    } catch (e) {
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get all live streams',
      );
    }
  }

  Future<MerchantLiveStreamsVM?> getLiveStreamById(int id) async {
    try {
      final liveStream = await _liveStreamRepository.getById(id);
      if (liveStream != null && liveStream.merchantId == currentMerchantId) {
        return MerchantLiveStreamsVM.fromRaw(liveStream);
      }
      return null;
    } catch (e) {
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get live stream',
      );
    }
  }

  // Basic CRUD operations
  Future<MerchantLiveStreamsVM?> createLiveStream(
    CreateLiveStreamDTO dto,
  ) async {
    try {
      final liveStreamModel = LiveStreamModel(
        id: 0,
        merchantId: currentMerchantId,
        title: dto.title,
        streamUrl: dto.streamUrl,
        thumbnailUrl: dto.thumbnailUrl,
        viewCount: 0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      final id = await _liveStreamRepository.insert(liveStreamModel);
      final newLiveStream = await _liveStreamRepository.getById(id);
      if (newLiveStream != null) {
        return MerchantLiveStreamsVM.fromRaw(newLiveStream);
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

  Future<MerchantLiveStreamsVM?> updateLiveStream(
    int id,
    UpdateLiveStreamDTO dto,
  ) async {
    try {
      final liveStream = await _liveStreamRepository.getById(id);
      if (liveStream == null || liveStream.merchantId != currentMerchantId) {
        return null;
      }
      final liveStreamModel = LiveStreamModel(
        id: id,
        merchantId: liveStream.merchantId,
        title: dto.title ?? liveStream.title,
        streamUrl: dto.streamUrl ?? liveStream.streamUrl,
        thumbnailUrl: dto.thumbnailUrl ?? liveStream.thumbnailUrl,
        viewCount: liveStream.viewCount,
        createdAt: liveStream.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _liveStreamRepository.update(liveStreamModel);
      final newLiveStream = await _liveStreamRepository.getById(id);
      if (newLiveStream != null) {
        return MerchantLiveStreamsVM.fromRaw(newLiveStream);
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
