import 'package:dak_louk/data/repositories/chat_repo.dart';
import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/chat_room_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ChatService {
  final ChatRepository _chatRepository = ChatRepository();
  final ChatRoomRepository _chatRoomRepository = ChatRoomRepository();
  late final currentMerchantId;
  ChatService() {
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
  // Migrated from ChatDao.insertChat
  Future<int> createChat(CreateChatDTO dto) async {
    try {
      final chatModel = ChatModel(
        id: 0,
        senderId: currentMerchantId,
        text: dto.text,
        chatRoomId: dto.chatRoomId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return await _chatRepository.insert(chatModel);
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create chat',
      );
    }
  }

  // // Migrated from ChatDao.getChatsByUserIdAndTargetUserId
  // Future<List<ChatModel>> getChatWithMerchant(int merchantId) async {
  //   try {
  //     // Find chat room between the two users
  //     final userStatement1 = Clauses.where.eq(
  //       Tables.chatRooms.cols.userId,
  //       merchantId,
  //     );
  //     final targetStatement1 = Clauses.where.eq(
  //       Tables.chatRooms.cols.merchantId,
  //       merchantId,
  //     );
  //     final orStatement1 = Clauses.where.and([
  //       userStatement1,
  //       targetStatement1,
  //     ]);

  //     final userStatement2 = Clauses.where.eq(
  //       Tables.chatRooms.cols.userId,
  //       merchantId,
  //     );
  //     final targetStatement2 = Clauses.where.eq(
  //       Tables.chatRooms.cols.merchantId,
  //       currentMerchantId,
  //     );
  //     final orStatement2 = Clauses.where.and([
  //       userStatement2,
  //       targetStatement2,
  //     ]);

  //     // Query for chat room with OR condition
  //     final chatRooms1 = await _chatRoomRepository.queryThisTable(
  //       where: orStatement1.clause,
  //       args: orStatement1.args,
  //       limit: 1,
  //     );

  //     final chatRooms2 = await _chatRoomRepository.queryThisTable(
  //       where: orStatement2.clause,
  //       args: orStatement2.args,
  //       limit: 1,
  //     );

  //     final chatRooms = [...chatRooms1, ...chatRooms2];

  //     if (chatRooms.isNotEmpty) {
  //       final chatRoomId = chatRooms.first.id;
  //       return getChatByChatRoomId(chatRoomId);
  //     }
  //     return [];
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Migrated from ChatDao.getChatByChatRoomId
  Future<List<ChatVM>> getChatsByChatRoomId(int chatRoomId) async {
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
            return ChatVM.fromRaw(
              chat,
              isMine: chat.senderId == AppSession.instance.userId,
            );
          }),
        );
        return enrichedChats;
      }

      // Return empty chat as in DAO
      return [
        ChatVM.fromRaw(
          ChatModel(
            id: 0,
            chatRoomId: chatRoomId,
            senderId: 0,
            text: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          isMine: false,
        ),
      ];
    } catch (e) {
      rethrow;
    }
  }

  // // Migrated from ChatDao.deleteChat
  // Future<int> deleteChat(int id) async {
  //   try {
  //     final chat = await _chatRepository.getById(id);
  //     if (chat == null) {
  //       throw AppError(type: ErrorType.NOT_FOUND, message: 'Chat not found');
  //     }
  //     if (chat.senderId != currentMerchantId) {
  //       throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
  //     }
  //     return await _chatRepository.delete(id);
  //   } catch (e) {
  //     if (e is AppError) {
  //       rethrow;
  //     }
  //     throw AppError(
  //       type: ErrorType.DB_ERROR,
  //       message: 'Failed to delete chat',
  //     );
  //   }
  // }

  // // Migrated from ChatDao.getLatestChatByChatRoomId
  // Future<ChatVM> getLatestChatByChatRoomId(int chatRoomId) async {
  //   try {
  //     final statement = Clauses.where.eq(
  //       Tables.chats.cols.chatRoomId,
  //       chatRoomId,
  //     );
  //     final orderByStmt = Clauses.orderBy.desc(Tables.chats.cols.createdAt);

  //     final result = await _chatRepository.queryThisTable(
  //       where: statement.clause,
  //       args: statement.args,
  //       orderBy: orderByStmt.clause,
  //       limit: 1,
  //     );

  //     if (result.isNotEmpty) {
  //       final chat = result.first;
  //       return ChatVM.fromRaw(
  //         chat,
  //         isMine: chat.senderId == AppSession.instance.userId,
  //       );
  //     }
  //     throw Exception('Chat not found');
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Additional CRUD methods

  Future<List<ChatVM>> getAllChats() async {
    // Placeholder - implement later
    throw UnimplementedError('getAllChats not implemented');
  }

  Future<ChatVM?> getChatById(int id) async {
    // Placeholder - implement later
    throw UnimplementedError('getChatById not implemented');
  }

  Future<ChatVM?> updateChat(int id, UpdateChatDTO dto) async {
    // Placeholder - implement later
    throw UnimplementedError('updateChat not implemented');
  }

  Future<void> deleteChat(int id) async {
    // Placeholder - implement later
    throw UnimplementedError('deleteChat not implemented');
  }
}
