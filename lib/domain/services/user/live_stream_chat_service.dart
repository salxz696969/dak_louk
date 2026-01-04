import 'package:dak_louk/data/repositories/live_stream_chat_repo.dart';
import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/cache/cache.dart';

class LiveStreamChatService {
  late final currentUserId;
  final LiveStreamChatRepository _liveStreamChatRepository =
      LiveStreamChatRepository();
  final UserRepository _userRepository = UserRepository();
  final Cache _cache = Cache();
  late final String _baseCacheKey;
  LiveStreamChatService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
      _baseCacheKey = 'service:user:$currentUserId:live_stream_chat';
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  // Business logic methods migrated from LiveStreamChatRepository
  Future<List<LiveStreamChatVM>> getAllLiveStreamChatByLiveStreamId(
    int liveStreamId,
  ) async {
    try {
      final cacheKey =
          '$_baseCacheKey:getAllLiveStreamChatByLiveStreamId:$liveStreamId';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectMany(cached).cast<LiveStreamChatVM>().toList();
      }

      final statement = Clauses.where.eq(
        Tables.liveStreamChats.cols.liveStreamId,
        liveStreamId,
      );
      final chats = await _liveStreamChatRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );

      final chatsVM = <LiveStreamChatVM>[];
      if (chats.isNotEmpty) {
        for (var chat in chats) {
          final user = await _userRepository.getById(chat.userId);
          if (user != null) {
            chatsVM.add(
              LiveStreamChatVM.fromRaw(
                chat,
                username: user.username,
                profileImage: user.profileImageUrl ?? '',
              ),
            );
          }
        }
        // Populate user relations like in the original DAO
        _cache.set(cacheKey, Many(chatsVM));
        return chatsVM;
      }
      throw Exception('LiveStreamChat not found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get live stream chat',
      );
    }
  }

  // Basic CRUD operations
  Future<LiveStreamChatVM?> createLiveStreamChat(
    CreateLiveStreamChatDTO dto,
  ) async {
    try {
      final chatModel = LiveStreamChatModel(
        id: 0,
        text: dto.text,
        userId: currentUserId,
        liveStreamId: dto.liveStreamId,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      final id = await _liveStreamChatRepository.insert(chatModel);
      if (id > 0) {
        final newChat = await _liveStreamChatRepository.getById(id);
        if (newChat != null) {
          final user = await _userRepository.getById(newChat.userId);
          if (user != null) {
            // Invalidate cache for this live stream's chats
            _cache.del(
              '$_baseCacheKey:getAllLiveStreamChatByLiveStreamId:${dto.liveStreamId}',
            );
            return LiveStreamChatVM.fromRaw(
              newChat,
              username: user.username,
              profileImage: user.profileImageUrl ?? '',
            );
          }
          throw AppError(
            type: ErrorType.NOT_FOUND,
            message: 'Live stream chat not found',
          );
        }
        throw AppError(type: ErrorType.NOT_FOUND, message: 'User not found');
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create live stream chat',
      );
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create live stream chat',
      );
    }
  }
}
