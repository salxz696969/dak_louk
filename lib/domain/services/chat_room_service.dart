import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/chat_room_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ChatRoomService {
  late final currentUserId;
  final ChatRoomRepository _chatRoomRepository = ChatRoomRepository();
  ChatRoomService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  // Migrated from ChatRoomDao.insertChatRoom
  Future<int> createChatRoom(CreateChatRoomDTO dto) async {
    try {
      final chatRoomModel = ChatRoomModel(
        id: 0,
        userId: currentUserId,
        merchantId: dto.merchantId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return await _chatRoomRepository.insert(chatRoomModel);
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create chat room',
      );
    }
  }

  // Migrated from ChatRoomDao.getChatRoomId
  Future<int> getChatRoomId(int targetUserId) async {
    try {
      // Check both directions of the relationship
      final userStatement1 = Clauses.where.eq(
        Tables.chatRooms.cols.userId,
        currentUserId,
      );
      final targetStatement1 = Clauses.where.eq(
        Tables.chatRooms.cols.merchantId,
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
        Tables.chatRooms.cols.merchantId,
        currentUserId,
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
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get chat room id',
      );
    }
  }

  // Migrated from ChatRoomDao.getAllChatRoomsByUserId
  Future<List<ChatRoomVM>> getAllChatRooms() async {
    try {
      final statement = Clauses.where.eq(
        Tables.chatRooms.cols.userId,
        currentUserId,
      );
      final result = await _chatRoomRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        limit: 50,
      );

      if (result.isNotEmpty) {
        // Populate relations like in the original DAO
        final enrichedChatRooms = await Future.wait(
          result.map((chatRoom) async {
            return ChatRoomVM.fromRaw(chatRoom);
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
