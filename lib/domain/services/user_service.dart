import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/repositories/post_repo.dart';
import 'package:dak_louk/data/repositories/post_like_repo.dart';
import 'package:dak_louk/data/repositories/post_save_repo.dart';
import 'package:dak_louk/data/repositories/promo_media_repo.dart';
import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/domain/models/models.dart';

class UserService {
  late int currentUserId;
  final UserRepository _userRepository = UserRepository();
  final PostRepository _postRepository = PostRepository();
  final PostLikeRepository _postLikeRepository = PostLikeRepository();
  final PostSaveRepository _postSaveRepository = PostSaveRepository();
  final PromoMediaRepository _promoMediaRepository = PromoMediaRepository();

  UserService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId!;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  Future<UserModel?> getUserById(int id) async {
    try {
      final newUser = await _userRepository.getById(id);
      if (newUser != null) {
        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfileVM> getUserProfile() async {
    try {
      final user = await _userRepository.getById(currentUserId);
      if (user != null) {
        // Compose the UserProfileVM manually since there is no fromRaw
        return UserProfileVM(
          id: user.id,
          username: user.username,
          profileImageUrl: user.profileImageUrl ?? '',
          bio: user.bio ?? '',
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
        );
      } else {
        throw AppError(type: ErrorType.NOT_FOUND, message: 'User not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Returns a list of liked posts for the current user.
  Future<List<UserProfileLikedSavedPostsVM>> getLikedPosts() async {
    try {
      final likedPosts = await _postLikeRepository.queryThisTable(
        where: Clauses.where
            .eq(Tables.postLikes.cols.userId, currentUserId)
            .clause,
        args: Clauses.where
            .eq(Tables.postLikes.cols.userId, currentUserId)
            .args,
      );
      final userLikedPosts = <UserProfileLikedSavedPostsVM>[];
      for (final like in likedPosts) {
        final post = await _postRepository.getById(like.postId);
        final media = await _promoMediaRepository.queryThisTable(
          where: Clauses.where
              .eq(Tables.promoMedias.cols.postId, post!.id)
              .clause,
          args: Clauses.where.eq(Tables.promoMedias.cols.postId, post.id).args,
        );
        if (post != null && media.isNotEmpty) {
          userLikedPosts.add(
            UserProfileLikedSavedPostsVM(
              id: post.id,
              caption: post.caption ?? '',
              imageUrl: media.first.url,
            ),
          );
        }
      }
      return userLikedPosts;
    } catch (e) {
      rethrow;
    }
  }

  // Returns a list of saved posts for the current user.
  Future<List<UserProfileLikedSavedPostsVM>> getSavedPosts() async {
    try {
      final savedPosts = await _postSaveRepository.queryThisTable(
        where: Clauses.where
            .eq(Tables.postSaves.cols.userId, currentUserId)
            .clause,
        args: Clauses.where
            .eq(Tables.postSaves.cols.userId, currentUserId)
            .args,
      );
      final userSavedPosts = <UserProfileLikedSavedPostsVM>[];
      for (final save in savedPosts) {
        final post = await _postRepository.getById(save.postId);
        final media = await _promoMediaRepository.queryThisTable(
          where: Clauses.where
              .eq(Tables.promoMedias.cols.postId, post!.id)
              .clause,
          args: Clauses.where.eq(Tables.promoMedias.cols.postId, post.id).args,
        );
        if (post != null && media.isNotEmpty) {
          userSavedPosts.add(
            UserProfileLikedSavedPostsVM(
              id: post.id,
              caption: post.caption ?? '',
              imageUrl: media.first.url,
            ),
          );
        }
      }
      return userSavedPosts;
    } catch (e) {
      rethrow;
    }
  }
}
