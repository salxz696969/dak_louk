import 'package:dak_louk/data/repositories/post_save_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/cache/cache.dart';

class PostSaveService {
  late final currentUserId;
  final Cache _cache = Cache();
  late final String merchantSideCacheKeyPattern;
  PostSaveService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
      merchantSideCacheKeyPattern = 'service:merchant:*:post:*';
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }
  final PostSaveRepository _postSaveRepository = PostSaveRepository();

  Future<void> savePost(int postId) async {
    await _postSaveRepository.insert(
      PostSaveModel(
        id: 0,
        userId: currentUserId,
        postId: postId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // Invalidate merchant-side post caches
    _cache.delByPattern(merchantSideCacheKeyPattern);
  }

  Future<void> unsavePost(int postId) async {
    await _postSaveRepository.delete(postId);

    // Invalidate merchant-side post caches
    _cache.delByPattern(merchantSideCacheKeyPattern);
  }
}
