import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/core/utils/time_ago.dart' as time_ago;
import 'package:dak_louk/data/cache/cache.dart';
import 'package:dak_louk/data/repositories/chat_repo.dart';
import 'package:dak_louk/data/repositories/chat_room_repo.dart';
import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ChatRoomService {
  late final currentMerchantId;
  final ChatRoomRepository _chatRoomRepository = ChatRoomRepository();
  final UserRepository _userRepository = UserRepository();
  final ChatRepository _chatRepository = ChatRepository();
  final Cache _cache = Cache();
  late final String _baseCacheKey;
  ChatRoomService() {
    if (AppSession.instance.isLoggedIn &&
        AppSession.instance.merchantId != null) {
      currentMerchantId = AppSession.instance.merchantId;
      _baseCacheKey = 'service:merchant:$currentMerchantId:chat_room';
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
      final cacheKey = '$_baseCacheKey:getAllChatRooms';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectMany(cached).cast<MerchantChatRoomVM>().toList();
      }
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
              final timeAgo = time_ago.timeAgo(
                DateTime.parse(latestChat.createdAt),
              );
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
      _cache.set(cacheKey, Many(chatRoomsVM));
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
