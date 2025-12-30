import 'package:dak_louk/db/repositories/media_repo.dart';
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
  final MediaRepository _mediaRepository = MediaRepository();
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
          final statement = Clauses.where.eq(
            Tables.medias.cols.postId,
            post.id,
          );
          final mediaResults = await _mediaRepository.queryThisTable(
            where: statement.clause,
            args: statement.args,
          );
          final mediaUrls = mediaResults.map((media) => media.url).toList();

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
        final statement = Clauses.where.eq(
          Tables.posts.cols.category,
          category,
        );
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
          final statement = Clauses.where.eq(
            Tables.medias.cols.postId,
            post.id,
          );

          final mediaResults = await _mediaRepository.queryThisTable(
            where: statement.clause,
            args: statement.args,
          );
          final mediaUrls = mediaResults.map((media) => media.url).toList();

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
          final user = await _userRepository.getById(post.userId);
          final product = await _productRepository.getById(post.productId);

          // Get media URLs
          final statement = Clauses.where.eq(
            Tables.medias.cols.postId,
            post.id,
          );
          final mediaResults = await _mediaRepository.queryThisTable(
            where: statement.clause,
            args: statement.args,
          );
          final mediaUrls = mediaResults.map((media) => media.url).toList();

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
      await _mediaRepository.insert(
        MediaModel(
          id: 0,
          postId: postId,
          url: mediaUrl,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getPostMediaUrls(int postId) async {
    try {
      final statement = Clauses.where.eq(Tables.medias.cols.postId, postId);
      final mediaResults = await _mediaRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
      return mediaResults.map((media) => media.url).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Basic CRUD operations
  Future<PostModel?> createPost(
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
      final statement = Clauses.where.eq(Tables.medias.cols.postId, postId);
      final mediaResults = await _mediaRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
      for (final media in mediaResults) {
        await _mediaRepository.delete(media.postId);
      }

      // Delete the post
      await _postRepository.delete(postId);
    } catch (e) {
      rethrow;
    }
  }
}
