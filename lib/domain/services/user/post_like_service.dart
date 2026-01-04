import 'package:dak_louk/data/repositories/post_like_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/cache/cache.dart';

class PostLikeService {
  late final currentUserId;
  final PostLikeRepository _postLikeRepository = PostLikeRepository();
  final Cache _cache = Cache();
  late final String merchantSideCacheKeyPattern;
  PostLikeService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
      merchantSideCacheKeyPattern = 'service:merchant:*:post:*';
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  Future<void> likePost(int postId) async {
    await _postLikeRepository.insert(
      PostLikeModel(
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

  Future<void> unlikePost(int postId) async {
    await _postLikeRepository.delete(postId);

    // Invalidate merchant-side post caches
    _cache.delByPattern(merchantSideCacheKeyPattern);
  }
}
