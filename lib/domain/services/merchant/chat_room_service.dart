import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/core/utils/time_ago.dart' as time_ago;
import 'package:dak_louk/data/repositories/chat_repo.dart';
import 'package:dak_louk/data/repositories/chat_room_repo.dart';
import 'package:dak_louk/data/repositories/merchant_repo.dart';
import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ChatRoomService {
  late final currentMerchantId;
  final ChatRoomRepository _chatRoomRepository = ChatRoomRepository();
  final MerchantRepository _merchantRepository = MerchantRepository();
  final UserRepository _userRepository = UserRepository();
  final ChatRepository _chatRepository = ChatRepository();
  ChatRoomService() {
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

  // Migrated from ChatRoomDao.getAllChatRoomsByMerchantId
  Future<List<MerchantChatRoomVM?>> getAllChatRooms() async {
    try {
      final statement = Clauses.where.eq(
        Tables.chatRooms.cols.merchantId,
        currentMerchantId,
      );
      final chatRooms = await _chatRoomRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        limit: 50,
      );
      final chatRoomsVM = <MerchantChatRoomVM>[];
      if (chatRooms.isNotEmpty) {
        for (final chatRoom in chatRooms) {
          final user = await _userRepository.getById(chatRoom.userId);
          if (user != null) {
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
            if (chatRoomChats.isNotEmpty) {
              final latestChat = chatRoomChats.first;
              final timeAgo = time_ago.timeAgo(latestChat.createdAt);
              final latestText = latestChat.text;
              chatRoomsVM.add(
                MerchantChatRoomVM.fromRaw(
                  chatRoom,
                  buyerName: user.username, // Using user info for merchants
                  buyerProfileImage: user.profileImageUrl ?? '',
                  timeAgo: timeAgo,
                  latestText: latestText,
                ),
              );
            }
          }
        }
      }
      return chatRoomsVM;
    } catch (e) {
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
