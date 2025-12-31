import 'package:dak_louk/data/repositories/post_repo.dart';
import 'package:dak_louk/data/repositories/promo_media_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class PostService {
  final PostRepository _postRepository = PostRepository();
  final PromoMediaRepository _promoMediaRepository = PromoMediaRepository();
  // Business logic methods migrated from PostRepository
  Future<List<PostModel>> getPostsByUserId(int userId, int limit) async {
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
          return PostModel(
            id: post.id,
            merchantId: post.merchantId,
            caption: post.caption,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
          );
        }),
      );

      return enrichedPosts;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> getAllPosts(int limit) async {
    try {
      List<PostModel> posts;
      if (limit <= 0) limit = 100;

      posts = await _postRepository.queryThisTable(limit: limit);

      // Populate relations
      final enrichedPosts = await Future.wait(
        posts.map((post) async {
          return PostModel(
            id: post.id,
            merchantId: post.merchantId,
            caption: post.caption,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
          );
        }),
      );

      return enrichedPosts;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> getPostsByProductId(int productId) async {
    try {
      final statement = Clauses.where.eq(
        Tables.postProducts.cols.productId,
        productId,
      );
      return await _postRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Migrated from PostDao
  Future<List<PostModel>> getPostsByLiveStreamId(int liveStreamId) async {
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
          return PostModel(
            id: post.id,
            merchantId: post.merchantId,
            caption: post.caption,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
          );
        }),
      );

      return enrichedPosts;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> getRecentPosts({int limit = 20}) async {
    try {
      final orderByStmt = Clauses.orderBy.desc(Tables.posts.cols.createdAt);
      return await _postRepository.queryThisTable(
        orderBy: orderByStmt.clause,
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> searchPosts(String searchTerm) async {
    try {
      final statement = Clauses.like.like(
        Tables.posts.cols.caption,
        searchTerm,
      );
      return await _postRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Media management
  Future<void> addMediaToPost(PostModel post) async {
    try {
      await _postRepository.insert(post);
    } catch (e) {
      rethrow;
    }
  }

  // Basic CRUD operations
  Future<PostModel?> createPost(PostModel post) async {
    try {
      final id = await _postRepository.insert(post);

      final newPost = await _postRepository.getById(id);
      if (newPost != null) {
        return newPost;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<PostModel?> getPostById(int id) async {
    try {
      final newPost = await _postRepository.getById(id);
      if (newPost != null) {
        return newPost;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<PostModel?> updatePost(PostModel post) async {
    try {
      await _postRepository.update(post);
      final newPost = await _postRepository.getById(post.id);
      if (newPost != null) {
        return newPost;
      }
      return null;
    } catch (e) {
      rethrow;
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
      rethrow;
    }
  }
}
