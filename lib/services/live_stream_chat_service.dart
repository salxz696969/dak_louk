import 'package:dak_louk/db/repositories/live_stream_chat_repo.dart';
import 'package:dak_louk/db/repositories/user_repo.dart';
import 'package:dak_louk/models/live_stream_chat_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class LiveStreamChatService {
  final LiveStreamChatRepository _liveStreamChatRepository =
      LiveStreamChatRepository();
  final UserRepository _userRepository = UserRepository();

  // Business logic methods migrated from LiveStreamChatRepository
  Future<List<LiveStreamChatModel>> getAllLiveStreamChatByLiveStreamId(
    int liveStreamId,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.liveStreamChats.cols.liveStreamId,
        liveStreamId,
      );
      final result = await _liveStreamChatRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy
            .desc(Tables.liveStreamChats.cols.createdAt)
            .clause,
      );
      if (result.isNotEmpty) {
        return result;
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
          final user = await _userRepository.getById(chat.userId);
          return LiveStreamChatModel(
            id: chat.id,
            text: chat.text,
            userId: chat.userId,
            liveStreamId: chat.liveStreamId,
            createdAt: chat.createdAt,
            updatedAt: chat.updatedAt,
            user: user,
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
  Future<LiveStreamChatModel> sendMessage(LiveStreamChatModel chat) async {
    try {
      final id = await _liveStreamChatRepository.insert(chat);
      return await _liveStreamChatRepository.getById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<LiveStreamChatModel> getChatById(int id) async {
    try {
      return await _liveStreamChatRepository.getById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<LiveStreamChatModel> updateChat(LiveStreamChatModel chat) async {
    try {
      await _liveStreamChatRepository.update(chat);
      return await _liveStreamChatRepository.getById(chat.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteChat(int chatId) async {
    try {
      await _liveStreamChatRepository.delete(chatId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStreamChatModel>> getAllChats() async {
    try {
      return await _liveStreamChatRepository.getAll();
    } catch (e) {
      rethrow;
    }
  }
}
