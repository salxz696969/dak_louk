import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/core/utils/time_ago.dart' as time_ago;
import 'package:dak_louk/data/repositories/chat_repo.dart';
import 'package:dak_louk/data/repositories/chat_room_repo.dart';
import 'package:dak_louk/data/repositories/merchant_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ChatRoomService {
  late final currentUserId;
  final ChatRoomRepository _chatRoomRepository = ChatRoomRepository();
  final MerchantRepository _merchantRepository = MerchantRepository();
  final ChatRepository _chatRepository = ChatRepository();
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
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
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
  Future<List<ChatRoomVM?>> getAllChatRooms() async {
    try {
      print('getAllChatRooms: querying chat rooms for user $currentUserId');
      final statement = Clauses.where.eq(
        Tables.chatRooms.cols.userId,
        currentUserId,
      );
      final chatRooms = await _chatRoomRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        limit: 50,
      );
      print('getAllChatRooms: found ${chatRooms.length} chat rooms');
      final chatRoomsVM = <ChatRoomVM>[];
      if (chatRooms.isNotEmpty) {
        for (final chatRoom in chatRooms) {
          print('getAllChatRooms: processing chatRoom.id=${chatRoom.id}');
          final merchant = await _merchantRepository.getById(
            chatRoom.merchantId,
          );
          if (merchant != null) {
            final chatRoomChats = await _chatRepository.queryThisTable(
              where: Clauses.where
                  .eq(Tables.chats.cols.chatRoomId, chatRoom.id)
                  .clause,
              args: Clauses.where
                  .eq(Tables.chats.cols.chatRoomId, chatRoom.id)
                  .args,
              limit: 1,
              orderBy: Clauses.orderBy.desc(Tables.chats.cols.createdAt).clause,
            );
            print('getAllChatRooms: found ${chatRoomChats.length} chats in chatRoom.id=${chatRoom.id}');
            if (chatRoomChats.isNotEmpty) {
              final latestChat = chatRoomChats.first;
              final timeAgo = DateTime.parse(latestChat.createdAt);
              final latestText = latestChat.text;
              print('getAllChatRooms: adding ChatRoomVM for chatRoom.id=${chatRoom.id} '
                  'merchant=${merchant.username}, latestText="$latestText", timeAgo=${timeAgo}');
              chatRoomsVM.add(
                ChatRoomVM.fromRaw(
                  chatRoom,
                  merchantName: merchant.username,
                  merchantProfileImage: merchant.profileImage,
                  timeAgo: time_ago.timeAgo(timeAgo),
                  latestText: latestText,
                ),
              );
            }
          } else {
            print('getAllChatRooms: merchant not found for merchantId=${chatRoom.merchantId}');
          }
        }
      }
      print('getAllChatRooms: returning ${chatRoomsVM.length} ChatRoomVMs');
      return chatRoomsVM;
    } catch (e) {
      print('getAllChatRooms: error - $e');
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get all chat rooms',
      );
    }
  }
}
