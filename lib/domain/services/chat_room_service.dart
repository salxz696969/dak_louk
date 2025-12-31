import 'package:dak_louk/data/repositories/chat_room_repo.dart';
import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/domain/models/index.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ChatRoomService {
  final ChatRoomRepository _chatRoomRepository = ChatRoomRepository();
  final UserRepository _userRepository = UserRepository();

  // Migrated from ChatRoomDao.insertChatRoom
  Future<int> insertChatRoom(ChatRoomModel chatRoom) async {
    try {
      return await _chatRoomRepository.insert(chatRoom);
    } catch (e) {
      rethrow;
    }
  }

  // Migrated from ChatRoomDao.getChatRoomId
  Future<int> getChatRoomId(int userId, int targetUserId) async {
    try {
      // Check both directions of the relationship
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

      // Query for chat room with first condition
      final chatRooms1 = await _chatRoomRepository.queryThisTable(
        where: orStatement1.clause,
        args: orStatement1.args,
        limit: 1,
      );

      if (chatRooms1.isNotEmpty) {
        return chatRooms1.first.id;
      }

      // Query for chat room with second condition
      final chatRooms2 = await _chatRoomRepository.queryThisTable(
        where: orStatement2.clause,
        args: orStatement2.args,
        limit: 1,
      );

      if (chatRooms2.isNotEmpty) {
        return chatRooms2.first.id;
      }

      return -1; // Not found
    } catch (e) {
      rethrow;
    }
  }

  // Migrated from ChatRoomDao.getAllChatRoomsByUserId
  Future<List<ChatRoomModel>> getAllChatRoomsByUserId(int userId) async {
    try {
      final statement = Clauses.where.eq(Tables.chatRooms.cols.userId, userId);
      final result = await _chatRoomRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        limit: 50,
      );

      if (result.isNotEmpty) {
        // Populate relations like in the original DAO
        final enrichedChatRooms = await Future.wait(
          result.map((chatRoom) async {
            final user = await _userRepository.getById(userId);
            final targetUser = await _userRepository.getById(
              chatRoom.targetUserId,
            );

            return ChatRoomModel(
              id: chatRoom.id,
              userId: chatRoom.userId,
              targetUserId: chatRoom.targetUserId,
              createdAt: chatRoom.createdAt,
              updatedAt: chatRoom.updatedAt,
              user: user,
              targetUser: targetUser,
            );
          }),
        );
        return enrichedChatRooms;
      }
      throw Exception('ChatRoom not found');
    } catch (e) {
      rethrow;
    }
  }
}
