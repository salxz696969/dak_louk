import 'package:dak_louk/data/repositories/live_stream_chat_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';

class LiveStreamChatService {
  late final currentUserId;
  final LiveStreamChatRepository _liveStreamChatRepository =
      LiveStreamChatRepository();
  LiveStreamChatService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  // Business logic methods migrated from LiveStreamChatRepository
  Future<List<LiveStreamChatModel>> getAllLiveStreamChatByLiveStreamId(
    int liveStreamId,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.liveStreamChats.cols.liveStreamId,
        liveStreamId,
      );
      final chats = await _liveStreamChatRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );

      if (chats.isNotEmpty) {
        // Populate user relations like in the original DAO
        final enrichedChats = await Future.wait(
          chats.map((chat) async {
            return LiveStreamChatModel(
              id: chat.id,
              text: chat.text,
              userId: chat.userId,
              liveStreamId: chat.liveStreamId,
              createdAt: chat.createdAt,
              updatedAt: chat.updatedAt,
            );
          }),
        );

        return enrichedChats;
      }
      throw Exception('LiveStreamChat not found');
    } catch (e) {
      rethrow;
    }
  }

  // Additional business logic methods
  Future<List<LiveStreamChatModel>> getRecentChatsForLiveStream(
    int liveStreamId, {
    int limit = 50,
  }) async {
    try {
      final statement = Clauses.where.eq(
        Tables.liveStreamChats.cols.liveStreamId,
        liveStreamId,
      );
      final orderByStmt = Clauses.orderBy.desc(
        Tables.liveStreamChats.cols.createdAt,
      );

      return await _liveStreamChatRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: orderByStmt.clause,
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStreamChatModel>> getChatsByUserId(int userId) async {
    try {
      final statement = Clauses.where.eq(
        Tables.liveStreamChats.cols.userId,
        userId,
      );
      final orderByStmt = Clauses.orderBy.desc(
        Tables.liveStreamChats.cols.createdAt,
      );

      return await _liveStreamChatRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: orderByStmt.clause,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStreamChatModel>> getChatsWithUserInfo(
    int liveStreamId, {
    int limit = 50,
  }) async {
    try {
      final chats = await getRecentChatsForLiveStream(
        liveStreamId,
        limit: limit,
      );

      // Populate user information for each chat
      final enrichedChats = await Future.wait(
        chats.map((chat) async {
          return LiveStreamChatModel(
            id: chat.id,
            text: chat.text,
            userId: chat.userId,
            liveStreamId: chat.liveStreamId,
            createdAt: chat.createdAt,
            updatedAt: chat.updatedAt,
          );
        }),
      );

      return enrichedChats;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getChatCountForLiveStream(int liveStreamId) async {
    try {
      final statement = Clauses.where.eq(
        Tables.liveStreamChats.cols.liveStreamId,
        liveStreamId,
      );
      final chats = await _liveStreamChatRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
      return chats.length;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStreamChatModel>> searchChatsInLiveStream(
    int liveStreamId,
    String searchTerm,
  ) async {
    try {
      final liveStreamStatement = Clauses.where.eq(
        Tables.liveStreamChats.cols.liveStreamId,
        liveStreamId,
      );
      final textStatement = Clauses.like.like(
        Tables.liveStreamChats.cols.text,
        searchTerm,
      );

      return await _liveStreamChatRepository.queryThisTable(
        where: liveStreamStatement.clause + ' AND ' + textStatement.clause,
        args: liveStreamStatement.args,
        orderBy: Clauses.orderBy
            .desc(Tables.liveStreamChats.cols.createdAt)
            .clause,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteChatsForLiveStream(int liveStreamId) async {
    try {
      final chats = await getAllLiveStreamChatByLiveStreamId(liveStreamId);
      for (final chat in chats) {
        await _liveStreamChatRepository.delete(chat.id);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUserChatsFromLiveStream(
    int userId,
    int liveStreamId,
  ) async {
    try {
      final userStatement = Clauses.where.eq(
        Tables.liveStreamChats.cols.userId,
        userId,
      );
      final liveStreamStatement = Clauses.where.eq(
        Tables.liveStreamChats.cols.liveStreamId,
        liveStreamId,
      );

      final combinedStatement = Clauses.where.and([
        userStatement,
        liveStreamStatement,
      ]);
      final chats = await _liveStreamChatRepository.queryThisTable(
        where: combinedStatement.clause,
        args: combinedStatement.args,
      );

      for (final chat in chats) {
        await _liveStreamChatRepository.delete(chat.id);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Basic CRUD operations
  Future<LiveStreamChatVM?> createLiveStreamChat(
    CreateLiveStreamChatDTO dto,
  ) async {
    try {
      final chatModel = LiveStreamChatModel(
        id: 0,
        text: dto.text,
        userId: currentUserId,
        liveStreamId: dto.liveStreamId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await _liveStreamChatRepository.insert(chatModel);
      if (id > 0) {
        final newChat = await _liveStreamChatRepository.getById(id);
        if (newChat != null) {
          return LiveStreamChatVM.fromRaw(newChat);
        }
        throw AppError(
          type: ErrorType.NOT_FOUND,
          message: 'Live stream chat not found',
        );
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create live stream chat',
      );
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create live stream chat',
      );
    }
  }

  Future<LiveStreamChatVM?> getLiveStreamChatById(int id) async {
    try {
      final chat = await _liveStreamChatRepository.getById(id);
      if (chat != null) {
        return LiveStreamChatVM.fromRaw(chat);
      }
      throw AppError(
        type: ErrorType.NOT_FOUND,
        message: 'Live stream chat not found',
      );
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get live stream chat',
      );
    }
  }

  Future<LiveStreamChatVM?> updateLiveStreamChat(
    int id,
    UpdateLiveStreamChatDTO dto,
  ) async {
    try {
      final chat = await _liveStreamChatRepository.getById(id);
      if (chat == null) {
        throw AppError(
          type: ErrorType.NOT_FOUND,
          message: 'Live stream chat not found',
        );
      }
      if (chat.userId != currentUserId) {
        throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
      }
      final chatModel = LiveStreamChatModel(
        id: id,
        text: dto.text ?? chat.text,
        userId: chat.userId,
        liveStreamId: chat.liveStreamId,
        createdAt: chat.createdAt,
        updatedAt: DateTime.now(),
      );
      await _liveStreamChatRepository.update(chatModel);
      final newChat = await _liveStreamChatRepository.getById(id);
      if (newChat != null) {
        return LiveStreamChatVM.fromRaw(newChat);
      }
      throw AppError(
        type: ErrorType.NOT_FOUND,
        message: 'Live stream chat not found',
      );
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to update live stream chat',
      );
    }
  }

  Future<void> deleteLiveStreamChat(int id) async {
    try {
      final chat = await _liveStreamChatRepository.getById(id);
      if (chat == null) {
        throw AppError(
          type: ErrorType.NOT_FOUND,
          message: 'Live stream chat not found',
        );
      }
      if (chat.userId != currentUserId) {
        throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
      }
      await _liveStreamChatRepository.delete(id);
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to delete live stream chat',
      );
    }
  }
}
