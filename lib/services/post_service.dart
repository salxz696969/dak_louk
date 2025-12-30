import 'package:dak_louk/db/repositories/post_repo.dart';
import 'package:dak_louk/db/repositories/product_repo.dart';
import 'package:dak_louk/db/repositories/user_repo.dart';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class PostService {
  final PostRepository _postRepository = PostRepository();
  final UserRepository _userRepository = UserRepository();
  final ProductRepository _productRepository = ProductRepository();

  // Business logic methods migrated from PostRepository
  Future<List<PostModel>> getPostsByUserId(int userId, int limit) async {
    try {
      final statement = Clauses.where.eq(Tables.posts.cols.userId, userId);
      final posts = await _postRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        limit: limit > 0 ? limit : 20,
      );

      // Populate relations
      final enrichedPosts = await Future.wait(
        posts.map((post) async {
          final user = await _userRepository.getById(post.userId);
          final product = await _productRepository.getById(post.productId);

          // Get media URLs
          final db = await _postRepository.database;
          final mediaResults = await db.query(
            'medias',
            where: 'post_id = ?',
            whereArgs: [post.id],
          );
          final mediaUrls = mediaResults
              .map((media) => media['url'] as String)
              .toList();

          return PostModel(
            id: post.id,
            userId: post.userId,
            title: post.title,
            productId: post.productId,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            product: product,
            user: user,
            images: mediaUrls,
          );
        }),
      );

      return enrichedPosts;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> getAllPosts(String category, int limit) async {
    try {
      List<PostModel> posts;
      if (limit <= 0) limit = 100;

      if (category == 'all') {
        posts = await _postRepository.queryThisTable(limit: limit);
      } else {
        final statement = Clauses.where.eq('category', category);
        posts = await _postRepository.queryThisTable(
          where: statement.clause,
          args: statement.args,
          limit: limit,
        );
      }

      // Populate relations
      final enrichedPosts = await Future.wait(
        posts.map((post) async {
          final user = await _userRepository.getById(post.userId);
          final product = await _productRepository.getById(post.productId);

          // Get media URLs
          final db = await _postRepository.database;
          final mediaResults = await db.query(
            'medias',
            where: 'post_id = ?',
            whereArgs: [post.id],
          );
          final mediaUrls = mediaResults
              .map((media) => media['url'] as String)
              .toList();

          return PostModel(
            id: post.id,
            userId: post.userId,
            title: post.title,
            productId: post.productId,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            product: product,
            user: user,
            images: mediaUrls,
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
        Tables.posts.cols.productId,
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
      final statement = Clauses.where.eq('live_stream_id', liveStreamId);
      final posts = await _postRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );

      // Populate relations like in the original DAO
      final enrichedPosts = await Future.wait(
        posts.map((post) async {
          final user = await _userRepository.getById(post.userId);
          final product = await _productRepository.getById(post.productId);

          // Get media URLs
          final db = await _postRepository.database;
          final mediaResults = await db.query(
            'medias',
            where: 'post_id = ?',
            whereArgs: [post.id],
          );
          final mediaUrls = mediaResults
              .map((media) => media['url'] as String)
              .toList();

          return PostModel(
            id: post.id,
            userId: post.userId,
            title: post.title,
            productId: post.productId,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            product: product,
            user: user,
            images: mediaUrls,
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
      final statement = Clauses.like.like(Tables.posts.cols.title, searchTerm);
      return await _postRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Media management
  Future<void> addMediaToPost(int postId, String mediaUrl) async {
    try {
      final db = await _postRepository.database;
      await db.insert('medias', {
        'post_id': postId,
        'url': mediaUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getPostMediaUrls(int postId) async {
    try {
      final db = await _postRepository.database;
      final mediaResults = await db.query(
        'medias',
        where: 'post_id = ?',
        whereArgs: [postId],
      );
      return mediaResults.map((media) => media['url'] as String).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Basic CRUD operations
  Future<PostModel> createPost(
    PostModel post, {
    List<String>? mediaUrls,
  }) async {
    try {
      final id = await _postRepository.insert(post);

      // Add media URLs if provided
      if (mediaUrls != null && mediaUrls.isNotEmpty) {
        for (final url in mediaUrls) {
          await addMediaToPost(id, url);
        }
      }

      return await _postRepository.getById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<PostModel> getPostById(int id) async {
    try {
      return await _postRepository.getById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<PostModel> updatePost(PostModel post) async {
    try {
      await _postRepository.update(post);
      return await _postRepository.getById(post.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      // Delete associated media first
      final db = await _postRepository.database;
      await db.delete('medias', where: 'post_id = ?', whereArgs: [postId]);

      // Delete the post
      await _postRepository.delete(postId);
    } catch (e) {
      rethrow;
    }
  }
}
