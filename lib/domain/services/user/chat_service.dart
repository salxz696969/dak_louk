import 'package:dak_louk/data/repositories/chat_repo.dart';
import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ChatService {
  final ChatRepository _chatRepository = ChatRepository();
  late final currentUserId;
  ChatService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }
  // Migrated from ChatDao.insertChat
  Future<ChatVM?> createChat(CreateChatDTO dto) async {
    try {
      // Nicely log the incoming DTO
      print(
        '[ChatService] Creating chat with DTO: {\n'
        '  chatRoomId: ${dto.chatRoomId},\n'
        '  text: "${dto.text}"\n'
        '}',
      );
      final chatModel = ChatModel(
        id: 0,
        senderId: currentUserId,
        text: dto.text,
        chatRoomId: dto.chatRoomId,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      // Nicely log the model about to be inserted
      print(
        '[ChatService] Inserting ChatModel: {\n'
        '  id: ${chatModel.id},\n'
        '  senderId: ${chatModel.senderId},\n'
        '  chatRoomId: ${chatModel.chatRoomId},\n'
        '  text: "${chatModel.text}",\n'
        '  createdAt: ${chatModel.createdAt},\n'
        '  updatedAt: ${chatModel.updatedAt}\n'
        '}',
      );
      final id = await _chatRepository.insert(chatModel);
      if (id > 0) {
        final newChat = await _chatRepository.getById(id);
        if (newChat != null) {
          return ChatVM.fromRaw(newChat, isMine: true);
        }
        throw AppError(type: ErrorType.NOT_FOUND, message: 'Chat not found');
      }
      return null;
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
  //       currentUserId,
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
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
          isMine: false,
        ),
      ];
    } catch (e) {
      rethrow;
    }
  }

  // // Migrated from ChatDao.updateChat
  // Future<int> updateChat(int id, UpdateChatDTO dto) async {
  //   try {
  //     final chat = await _chatRepository.getById(id);
  //     if (chat == null) {
  //       throw AppError(type: ErrorType.NOT_FOUND, message: 'Chat not found');
  //     }
  //     if (chat.senderId != currentUserId) {
  //       throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
  //     }
  //     final chatModel = ChatModel(
  //       id: id,
  //       senderId: currentUserId,
  //       text: dto.text ?? chat.text,
  //       chatRoomId: chat.chatRoomId,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //     );
  //     return await _chatRepository.update(chatModel);
  //   } catch (e) {
  //     if (e is AppError) {
  //       rethrow;
  //     }
  //     throw AppError(
  //       type: ErrorType.DB_ERROR,
  //       message: 'Failed to update chat',
  //     );
  //   }
  // }

  // // Migrated from ChatDao.deleteChat
  // Future<int> deleteChat(int id) async {
  //   try {
  //     final chat = await _chatRepository.getById(id);
  //     if (chat == null) {
  //       throw AppError(type: ErrorType.NOT_FOUND, message: 'Chat not found');
  //     }
  //     if (chat.senderId != currentUserId) {
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
}
