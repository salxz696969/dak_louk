import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/post_repo.dart';
import 'package:dak_louk/data/repositories/promo_media_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class PostService {
  late final currentUserId;
  final PostRepository _postRepository = PostRepository();
  final PromoMediaRepository _promoMediaRepository = PromoMediaRepository();
  // Business logic methods migrated from PostRepository
  PostService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }
  Future<List<PostVM>> getPostsByUserId(int userId, int limit) async {
    try {
      final statement = Clauses.where.eq(Tables.posts.cols.merchantId, userId);
      final posts = await _postRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        limit: limit > 0 ? limit : 20,
      );

      // Populate relations
      final enrichedPosts = await Future.wait(
        posts.map((post) async {
          return PostVM.fromRaw(post);
        }),
      );

      return enrichedPosts;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostVM>> getAllPosts(int limit) async {
    try {
      List<PostModel> posts;
      if (limit <= 0) limit = 100;

      posts = await _postRepository.queryThisTable(limit: limit);

      // Populate relations
      final enrichedPosts = await Future.wait(
        posts.map((post) async {
          return PostVM.fromRaw(post);
        }),
      );

      return enrichedPosts;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostVM>> getPostsByProductId(int productId) async {
    try {
      final statement = Clauses.where.eq(
        Tables.postProducts.cols.productId,
        productId,
      );
      final posts = await _postRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
      if (posts.isNotEmpty) {
        return posts.map((post) => PostVM.fromRaw(post)).toList();
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'No posts found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get posts by product id',
      );
    }
  }

  // Migrated from PostDao
  Future<List<PostVM>> getPostsByLiveStreamId(int liveStreamId) async {
    try {
      final statement = Clauses.where.eq(
        Tables.liveStreams.cols.id,
        liveStreamId,
      );
      final posts = await _postRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );

      // Populate relations like in the original DAO
      final enrichedPosts = await Future.wait(
        posts.map((post) async {
          return PostVM.fromRaw(post);
        }),
      );

      return enrichedPosts;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get posts by live stream id',
      );
    }
  }

  Future<List<PostVM>> getRecentPosts({int limit = 20}) async {
    try {
      final orderByStmt = Clauses.orderBy.desc(Tables.posts.cols.createdAt);
      final posts = await _postRepository.queryThisTable(
        orderBy: orderByStmt.clause,
        limit: limit,
      );
      if (posts.isNotEmpty) {
        return posts.map((post) => PostVM.fromRaw(post)).toList();
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'No posts found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get recent posts',
      );
    }
  }

  Future<List<PostVM>> searchPosts(String searchTerm) async {
    try {
      final statement = Clauses.like.like(
        Tables.posts.cols.caption,
        searchTerm,
      );
      final posts = await _postRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
      if (posts.isNotEmpty) {
        return posts.map((post) => PostVM.fromRaw(post)).toList();
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'No posts found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to search posts',
      );
    }
  }

  // Basic CRUD operations
  Future<PostVM?> createPost(CreatePostDTO dto) async {
    try {
      final id = await _postRepository.insert(
        PostModel(
          id: 0,
          merchantId: currentUserId,
          caption: dto.caption,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final newPost = await _postRepository.getById(id);
      if (newPost != null) {
        return PostVM.fromRaw(newPost);
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'Post not found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create post',
      );
    }
  }

  Future<PostVM?> getPostById(int id) async {
    try {
      final newPost = await _postRepository.getById(id);
      if (newPost != null) {
        return PostVM.fromRaw(newPost);
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'Post not found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get post by id',
      );
    }
  }

  Future<PostVM?> updatePost(int id, UpdatePostDTO dto) async {
    try {
      final post = await _postRepository.getById(id);
      if (post == null) {
        throw AppError(type: ErrorType.NOT_FOUND, message: 'Post not found');
      }
      if (post.merchantId != currentUserId) {
        throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
      }
      await _postRepository.update(
        PostModel(
          id: id,
          merchantId: currentUserId,
          caption: dto.caption,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      final newPost = await _postRepository.getById(post.id);
      if (newPost != null) {
        return PostVM.fromRaw(newPost);
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'Post not found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to update post',
      );
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      // Delete associated media first
      final statement = Clauses.where.eq(
        Tables.promoMedias.cols.postId,
        postId,
      );
      final promoMedias = await _promoMediaRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
      for (final promoMedia in promoMedias) {
        await _promoMediaRepository.delete(promoMedia.id);
      }
      await _postRepository.delete(postId);
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to delete post',
      );
    }
  }
}
