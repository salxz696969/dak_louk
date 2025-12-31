import 'package:dak_louk/data/repositories/chat_repo.dart';
import 'package:dak_louk/data/repositories/chat_room_repo.dart';
import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/domain/models/index.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ChatService {
  final ChatRepository _chatRepository = ChatRepository();
  final ChatRoomRepository _chatRoomRepository = ChatRoomRepository();
  final UserRepository _userRepository = UserRepository();

  // Migrated from ChatDao.insertChat
  Future<int> insertChat(ChatModel chat) async {
    try {
      return await _chatRepository.insert(chat);
    } catch (e) {
      rethrow;
    }
  }

  // Migrated from ChatDao.getChatsByUserIdAndTargetUserId
  Future<List<ChatModel>> getChatsByUserIdAndTargetUserId(
    int userId,
    int targetUserId,
  ) async {
    try {
      // Find chat room between the two users
      final userStatement1 = Clauses.where.eq(
        Tables.chatRooms.cols.userId,
        userId,
      );
      final targetStatement1 = Clauses.where.eq(
        Tables.chatRooms.cols.targetUserId,
        targetUserId,
      );
      final orStatement1 = Clauses.where.and([
        userStatement1,
        targetStatement1,
      ]);

      final userStatement2 = Clauses.where.eq(
        Tables.chatRooms.cols.userId,
        targetUserId,
      );
      final targetStatement2 = Clauses.where.eq(
        Tables.chatRooms.cols.targetUserId,
        userId,
      );
      final orStatement2 = Clauses.where.and([
        userStatement2,
        targetStatement2,
      ]);

      // Query for chat room with OR condition
      final chatRooms1 = await _chatRoomRepository.queryThisTable(
        where: orStatement1.clause,
        args: orStatement1.args,
        limit: 1,
      );

      final chatRooms2 = await _chatRoomRepository.queryThisTable(
        where: orStatement2.clause,
        args: orStatement2.args,
        limit: 1,
      );

      final chatRooms = [...chatRooms1, ...chatRooms2];

      if (chatRooms.isNotEmpty) {
        final chatRoomId = chatRooms.first.id;
        return getChatByChatRoomId(chatRoomId);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Migrated from ChatDao.getChatByChatRoomId
  Future<List<ChatModel>> getChatByChatRoomId(int chatRoomId) async {
    try {
      final statement = Clauses.where.eq(
        Tables.chats.cols.chatRoomId,
        chatRoomId,
      );
      final result = await _chatRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );

      if (result.isNotEmpty) {
        // Populate user information for each chat
        final enrichedChats = await Future.wait(
          result.map((chat) async {
            final user = await _userRepository.getById(chat.userId);
            return ChatModel(
              id: chat.id,
              userId: chat.userId,
              text: chat.text,
              chatRoomId: chat.chatRoomId,
              createdAt: chat.createdAt,
              updatedAt: chat.updatedAt,
              user: user,
            );
          }),
        );
        return enrichedChats;
      }

      // Return empty chat as in DAO
      return [
        ChatModel(
          id: 0,
          userId: 0,
          text: '',
          chatRoomId: chatRoomId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      rethrow;
    }
  }

  // Migrated from ChatDao.updateChat
  Future<int> updateChat(ChatModel chat) async {
    try {
      return await _chatRepository.update(chat);
    } catch (e) {
      rethrow;
    }
  }

  // Migrated from ChatDao.deleteChat
  Future<int> deleteChat(int id) async {
    try {
      return await _chatRepository.delete(id);
    } catch (e) {
      rethrow;
    }
  }

  // Migrated from ChatDao.getLatestChatByChatRoomId
  Future<ChatModel> getLatestChatByChatRoomId(int chatRoomId) async {
    try {
      final statement = Clauses.where.eq(
        Tables.chats.cols.chatRoomId,
        chatRoomId,
      );
      final orderByStmt = Clauses.orderBy.desc(Tables.chats.cols.createdAt);

      final result = await _chatRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: orderByStmt.clause,
        limit: 1,
      );

      if (result.isNotEmpty) {
        final chat = result.first;
        final user = await _userRepository.getById(chat.userId);
        return ChatModel(
          id: chat.id,
          userId: chat.userId,
          text: chat.text,
          chatRoomId: chat.chatRoomId,
          createdAt: chat.createdAt,
          updatedAt: chat.updatedAt,
          user: user,
        );
      }
      throw Exception('Chat not found');
    } catch (e) {
      rethrow;
    }
  }
}
