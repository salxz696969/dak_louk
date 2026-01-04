import 'package:dak_louk/data/repositories/chat_repo.dart';
import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/cache/cache.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ChatService {
  final ChatRepository _chatRepository = ChatRepository();
  final Cache _cache = Cache();
  late final currentMerchantId;
  late final String _baseCacheKey;
  ChatService() {
    if (AppSession.instance.isLoggedIn &&
        AppSession.instance.merchantId != null) {
      currentMerchantId = AppSession.instance.merchantId;
      _baseCacheKey = 'service:merchant:$currentMerchantId:chat';
    } else {
      throw AppError(
        type: ErrorType.UNAUTHORIZED,
        message: 'Unauthorized - No merchant session',
      );
    }
  }

  Future<int> createChat(CreateChatDTO dto) async {
    try {
      final chatModel = ChatModel(
        id: 0,
        senderId: currentMerchantId,
        text: dto.text,
        chatRoomId: dto.chatRoomId,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final id = await _chatRepository.insert(chatModel);
      // !too risky to aggregate update so ill just invalidate and let the next read cache a new one
      // final cachedChats = await _cache
      //     .get('$_baseCacheKey:getChatsByChatRoomId:${dto.chatRoomId}')
      //     ?.many;
      // cachedChats?.add(
      //   ChatModel(
      //     id: id,
      //     senderId: currentMerchantId,
      //     text: dto.text,
      //     chatRoomId: dto.chatRoomId,
      //     createdAt: DateTime.now().toIso8601String(),
      //     updatedAt: DateTime.now().toIso8601String(),
      //   ),
      // );
      // _cache.set(
      //   '$_baseCacheKey:getChatsByChatRoomId:${dto.chatRoomId}',
      //   Many(cachedChats ?? []),
      // );

      _cache.del('$_baseCacheKey:getChatsByChatRoomId:${dto.chatRoomId}');

      return id;
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
  Future<List<MerchantChatVM>> getChatsByChatRoomId(int chatRoomId) async {
    try {
      final cacheKey = '$_baseCacheKey:getChatsByChatRoomId:$chatRoomId';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectMany(cached).cast<MerchantChatVM>().toList();
      }

      final statement = Clauses.where.eq(
        Tables.chats.cols.chatRoomId,
        chatRoomId,
      );
      final result = await _chatRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );

      final enrichedChats = <MerchantChatVM>[];
      if (result.isNotEmpty) {
        // Populate user information for each chat
        enrichedChats.addAll(
          await Future.wait(
            result.map((chat) async {
              return MerchantChatVM.fromRaw(
                chat,
                isMine: chat.senderId == currentMerchantId,
              );
            }),
          ),
        );
      } else {
        // Return empty chat as in DAO
        enrichedChats.add(
          MerchantChatVM.fromRaw(
            ChatModel(
              id: 0,
              chatRoomId: chatRoomId,
              senderId: currentMerchantId,
              text: '',
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            ),
            isMine: false,
          ),
        );
      }

      _cache.set(cacheKey, Many(enrichedChats));
      return enrichedChats;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get chats by chat room id',
      );
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

  // Future<List<ChatVM>> getAllChats() async {
  //   // Placeholder - implement later
  //   throw UnimplementedError('getAllChats not implemented');
  // }

  // Future<ChatVM?> getChatById(int id) async {
  //   // Placeholder - implement later
  //   throw UnimplementedError('getChatById not implemented');
  // }

  // Future<ChatVM?> updateChat(int id, UpdateChatDTO dto) async {
  //   // Placeholder - implement later
  //   throw UnimplementedError('updateChat not implemented');
  // }

  // Future<void> deleteChat(int id) async {
  //   // Placeholder - implement later
  //   throw UnimplementedError('deleteChat not implemented');
  // }
}
