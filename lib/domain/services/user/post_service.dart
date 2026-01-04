import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_model.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/cache/cache.dart';
import 'package:dak_louk/data/repositories/cart_repo.dart';
import 'package:dak_louk/data/repositories/merchant_repo.dart';
import 'package:dak_louk/data/repositories/product_repo.dart';
import 'package:dak_louk/data/repositories/product_media_repo.dart';
import 'package:dak_louk/data/repositories/product_category_repo.dart';
import 'package:dak_louk/data/repositories/product_category_maps_repo.dart';
import 'package:dak_louk/data/repositories/post_product_repo.dart';
import 'package:dak_louk/data/repositories/post_like_repo.dart';
import 'package:dak_louk/data/repositories/post_repo.dart';
import 'package:dak_louk/data/repositories/post_save_repo.dart';
import 'package:dak_louk/data/repositories/promo_media_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class PostService {
  late final currentUserId;
  final PostRepository _postRepository = PostRepository();
  final MerchantRepository _merchantRepository = MerchantRepository();
  final PostProductsRepository _postProductsRepository =
      PostProductsRepository();
  final PromoMediaRepository _promoMediaRepository = PromoMediaRepository();
  final PostLikeRepository _postLikeRepository = PostLikeRepository();
  final PostSaveRepository _postSaveRepository = PostSaveRepository();
  final ProductRepository _productRepository = ProductRepository();
  final ProductMediaRepository _productMediaRepository =
      ProductMediaRepository();
  final ProductCategoryRepository _productCategoryRepository =
      ProductCategoryRepository();
  final ProductCategoryMapsRepository _productCategoryMapsRepository =
      ProductCategoryMapsRepository();
  final CartRepository _cartRepository = CartRepository();
  final Cache _cache = Cache();
  late final String _baseCacheKey;
  late final String merchantSideCacheKeyPattern;

  // Business logic methods migrated from PostRepository
  PostService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
      _baseCacheKey = 'service:user:$currentUserId:post';
      merchantSideCacheKeyPattern = 'service:merchant:*:post:*';
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }
  // Future<List<PostVM>> getMerchantPosts(int merchantId) async {
  //   try {
  //     final statement = Clauses.where.eq(
  //       Tables.posts.cols.merchantId,
  //       merchantId,
  //     );
  //     final posts = await _postRepository.queryThisTable(
  //       where: statement.clause,
  //       args: statement.args,
  //     );

  //     // Populate relations
  //     final enrichedPosts = await Future.wait(
  //       posts.map((post) async {
  //         final products = await _postProductsRepository.queryThisTable(
  //           where: Clauses.where
  //               .eq(Tables.postProducts.cols.postId, post.id)
  //               .clause,
  //         );
  //         final merchant = await _merchantRepository.getById(post.merchantId);
  //         if (merchant == null) {
  //           throw AppError(
  //             type: ErrorType.NOT_FOUND,
  //             message: 'Merchant not found',
  //           );
  //         }
  //         return PostVM.fromRaw(
  //           post,
  //           merchantName: merchant.username,
  //           merchantProfileImage: merchant.profileImage,
  //           mediaUrls: [],
  //           productNames: [],
  //           likesCount: 0,
  //           savesCount: 0,
  //           isLiked: false,
  //           isSaved: false,
  //         );
  //       }),
  //     );

  //     return enrichedPosts;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<List<PostVM>> getAllPosts({
    ProductCategory category = ProductCategory.all,
    int limit = 100,
  }) async {
    try {
      final cacheKey = '$_baseCacheKey:getAllPosts:$category:$limit';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectMany(cached).cast<PostVM>().toList();
      }

      if (limit <= 0) limit = 100;

      List<PostModel> posts;

      if (category == ProductCategory.all) {
        // Get all posts if category is 'all'
        posts = await _postRepository.queryThisTable(limit: limit);
      } else {
        // Filter posts by category
        posts = await _getPostsByCategory(category, limit);
      }

      if (posts.isEmpty) return [];

      // Get all likes and saves for these posts
      final postLikes = await _postLikeRepository.queryThisTable();
      final postSaves = await _postSaveRepository.queryThisTable();

      // Populate relations for each post
      final enrichedPosts = await Future.wait(
        posts.map((post) async {
          // Get merchant info
          final merchant = await _merchantRepository.getById(post.merchantId);
          if (merchant == null) {
            throw AppError(
              type: ErrorType.NOT_FOUND,
              message: 'Merchant not found for post ${post.id}',
            );
          }

          // Get promo medias for this post
          final promoMedias = await _promoMediaRepository.queryThisTable(
            where: Clauses.where
                .eq(Tables.promoMedias.cols.postId, post.id)
                .clause,
            args: Clauses.where
                .eq(Tables.promoMedias.cols.postId, post.id)
                .args,
          );

          // Get post-product relationships
          final postProductRelations = await _postProductsRepository
              .queryThisTable(
                where: Clauses.where
                    .eq(Tables.postProducts.cols.postId, post.id)
                    .clause,
                args: Clauses.where
                    .eq(Tables.postProducts.cols.postId, post.id)
                    .args,
              );

          // Get products for this post
          final postProducts = <PostProductVM>[];
          for (final relation in postProductRelations) {
            final product = await _productRepository.getById(
              relation.productId,
            );
            if (product != null) {
              // Get product media
              final productMedias = await _productMediaRepository
                  .queryThisTable(
                    where: Clauses.where
                        .eq(Tables.productMedias.cols.productId, product.id)
                        .clause,
                    args: Clauses.where
                        .eq(Tables.productMedias.cols.productId, product.id)
                        .args,
                  );

              // Get product categories
              final categoryMaps = await _productCategoryMapsRepository
                  .queryThisTable(
                    where: Clauses.where
                        .eq(
                          Tables.productCategoryMaps.cols.productId,
                          product.id,
                        )
                        .clause,
                    args: Clauses.where
                        .eq(
                          Tables.productCategoryMaps.cols.productId,
                          product.id,
                        )
                        .args,
                  );

              ProductCategory category = ProductCategory.others; // default
              if (categoryMaps.isNotEmpty) {
                final categoryModel = await _productCategoryRepository.getById(
                  categoryMaps.first.categoryId,
                );
                if (categoryModel != null) {
                  // Convert string to enum
                  category = ProductCategory.values.firstWhere(
                    (e) => e.name == categoryModel.name,
                    orElse: () => ProductCategory.others,
                  );
                }
              }

              final isAddedToCart = await _cartRepository.queryThisTable(
                where: Clauses.where
                    .eq(Tables.carts.cols.productId, product.id)
                    .clause,
                args: Clauses.where
                    .eq(Tables.carts.cols.productId, product.id)
                    .args,
              );

              postProducts.add(
                PostProductVM(
                  id: product.id,
                  name: product.name,
                  medias: productMedias
                      .map(
                        (media) => MediaModel(
                          url: media.url,
                          type: media.mediaType == 'video'
                              ? MediaType.video
                              : MediaType.image,
                        ),
                      )
                      .toList(),
                  price: (product.price * 100).truncate() / 100,
                  quantity: product.quantity,
                  isAddedToCart: isAddedToCart.isNotEmpty,
                  description: product.description ?? '',
                  category: category,
                ),
              );
            }
          }

          final merchantVM = PostMerchantVM(
            id: merchant.id,
            bio: merchant.bio,
            name: merchant.username,
            profileImage: merchant.profileImage,
            username: merchant.username,
            rating: (merchant.rating * 100).truncate() / 100,
          );

          // Calculate likes and saves for this post
          final likesCount = postLikes
              .where((like) => like.postId == post.id)
              .length;
          final savesCount = postSaves
              .where((save) => save.postId == post.id)
              .length;
          final isLiked = postLikes.any(
            (like) => like.postId == post.id && like.userId == currentUserId,
          );
          final isSaved = postSaves.any(
            (save) => save.postId == post.id && save.userId == currentUserId,
          );

          return PostVM.fromRaw(
            post,
            promoMedias: promoMedias.isNotEmpty ? promoMedias : null,
            merchant: merchantVM,
            products: postProducts,
            likesCount: likesCount,
            savesCount: savesCount,
            isLiked: isLiked,
            isSaved: isSaved,
          );
        }),
      );

      _cache.set(cacheKey, Many(enrichedPosts));
      return enrichedPosts;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get all posts: ${e.toString()}',
      );
    }
  }

  // // Basic CRUD operations
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
      if (dto.productIds != null) {
        for (final productId in dto.productIds!) {
          await _postProductsRepository.insert(
            PostProductModel(id: 0, postId: id, productId: productId),
          );
        }
      }

      if (dto.promoMedias != null) {
        for (final media in dto.promoMedias!) {
          await _promoMediaRepository.insert(
            PromoMediaModel(
              id: 0,
              postId: id,
              url: media.url,
              mediaType: media.type == MediaType.video ? 'video' : 'image',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
      }

      final newPost = await _postRepository.getById(id);
      if (newPost != null) {
        final postVMs = await _buildPostVMs([newPost]);
        if (postVMs.isNotEmpty) {
          // Invalidate cache
          _cache.del('$_baseCacheKey:getAllPosts');
          _cache.del('$_baseCacheKey:getPostById:$id');
          _cache.delByPattern(merchantSideCacheKeyPattern);
          return postVMs.first;
        }
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
      final cacheKey = '$_baseCacheKey:getPostById:$id';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectSingle(cached) as PostVM;
      }

      final post = await _postRepository.getById(id);
      if (post != null) {
        final postVMs = await _buildPostVMs([post]);
        if (postVMs.isNotEmpty) {
          _cache.set(cacheKey, Single(postVMs.first));
          return postVMs.first;
        }
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

  // Future<PostVM?> updatePost(int id, UpdatePostDTO dto) async {
  //   try {
  //     final post = await _postRepository.getById(id);
  //     if (post == null) {
  //       throw AppError(type: ErrorType.NOT_FOUND, message: 'Post not found');
  //     }
  //     if (post.merchantId != currentUserId) {
  //       throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
  //     }
  //     await _postRepository.update(
  //       PostModel(
  //         id: id,
  //         merchantId: currentUserId,
  //         caption: dto.caption,
  //         createdAt: post.createdAt, // Keep original creation time
  //         updatedAt: DateTime.now(),
  //       ),
  //     );
  //     final updatedPost = await _postRepository.getById(id);
  //     if (updatedPost != null) {
  //       final postVMs = await _buildPostVMs([updatedPost]);
  //       return postVMs.isNotEmpty ? postVMs.first : null;
  //     }
  //     throw AppError(type: ErrorType.NOT_FOUND, message: 'Post not found');
  //   } catch (e) {
  //     if (e is AppError) {
  //       rethrow;
  //     }
  //     throw AppError(
  //       type: ErrorType.DB_ERROR,
  //       message: 'Failed to update post',
  //     );
  //   }
  // }

  // Future<void> deletePost(int postId) async {
  //   try {
  //     // Delete associated media first
  //     final statement = Clauses.where.eq(
  //       Tables.promoMedias.cols.postId,
  //       postId,
  //     );
  //     final promoMedias = await _promoMediaRepository.queryThisTable(
  //       where: statement.clause,
  //       args: statement.args,
  //     );
  //     for (final promoMedia in promoMedias) {
  //       await _promoMediaRepository.delete(promoMedia.id);
  //     }
  //     await _postRepository.delete(postId);
  //   } catch (e) {
  //     if (e is AppError) {
  //       rethrow;
  //     }
  //     throw AppError(
  //       type: ErrorType.DB_ERROR,
  //       message: 'Failed to delete post',
  //     );
  //   }
  // }

  Future<List<PostVM>> getSimilarPosts(int postId) async {
    try {
      final cacheKey = '$_baseCacheKey:getSimilarPosts:$postId';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectMany(cached).cast<PostVM>().toList();
      }

      final post = await _postRepository.getById(postId);
      if (post == null) {
        throw AppError(type: ErrorType.NOT_FOUND, message: 'Post not found');
      }
      final posts = await _postRepository.queryThisTable(
        where: Clauses.like
            .like(Tables.posts.cols.caption, post.caption!)
            .clause,
        args: Clauses.like.like(Tables.posts.cols.caption, post.caption!).args,
        limit: 10,
      );
      final result = await _buildPostVMs(posts);
      _cache.set(cacheKey, Many(result));
      return result;
    } catch (e) {
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get posts by merchant id',
      );
    }
  }

  // Helper method to build PostVMs from PostModels
  Future<List<PostVM>> _buildPostVMs(List<PostModel> posts) async {
    if (posts.isEmpty) return [];

    // Get all likes and saves
    final postLikes = await _postLikeRepository.queryThisTable();
    final postSaves = await _postSaveRepository.queryThisTable();

    final enrichedPosts = await Future.wait(
      posts.map((post) async {
        // Get merchant info
        final merchant = await _merchantRepository.getById(post.merchantId);
        if (merchant == null) {
          throw AppError(
            type: ErrorType.NOT_FOUND,
            message: 'Merchant not found for post ${post.id}',
          );
        }

        // Get post-product relationships
        final postProductRelations = await _postProductsRepository
            .queryThisTable(
              where: Clauses.where
                  .eq(Tables.postProducts.cols.postId, post.id)
                  .clause,
              args: Clauses.where
                  .eq(Tables.postProducts.cols.postId, post.id)
                  .args,
            );

        // Get products for this post
        final postProducts = <PostProductVM>[];
        for (final relation in postProductRelations) {
          final product = await _productRepository.getById(relation.productId);
          if (product != null) {
            // Get product media
            final productMedias = await _productMediaRepository.queryThisTable(
              where: Clauses.where
                  .eq(Tables.productMedias.cols.productId, product.id)
                  .clause,
              args: Clauses.where
                  .eq(Tables.productMedias.cols.productId, product.id)
                  .args,
            );

            // Get product categories
            final categoryMaps = await _productCategoryMapsRepository
                .queryThisTable(
                  where: Clauses.where
                      .eq(Tables.productCategoryMaps.cols.productId, product.id)
                      .clause,
                  args: Clauses.where
                      .eq(Tables.productCategoryMaps.cols.productId, product.id)
                      .args,
                );

            ProductCategory category = ProductCategory.others; // default
            if (categoryMaps.isNotEmpty) {
              final categoryModel = await _productCategoryRepository.getById(
                categoryMaps.first.categoryId,
              );
              if (categoryModel != null) {
                // Convert string to enum
                category = ProductCategory.values.firstWhere(
                  (e) => e.name == categoryModel.name,
                  orElse: () => ProductCategory.others,
                );
              }
            }

            final isAddedToCart = await _cartRepository.queryThisTable(
              where: Clauses.where
                  .eq(Tables.carts.cols.productId, product.id)
                  .clause,
              args: Clauses.where
                  .eq(Tables.carts.cols.productId, product.id)
                  .args,
            );
            postProducts.add(
              PostProductVM(
                id: product.id,
                name: product.name,
                medias: productMedias
                    .map(
                      (media) => MediaModel(
                        url: media.url,
                        type: media.mediaType == 'video'
                            ? MediaType.video
                            : MediaType.image,
                      ),
                    )
                    .toList(),
                price: (product.price * 100).truncate() / 100,
                quantity: product.quantity,
                description: product.description ?? '',
                category: category,
                isAddedToCart: isAddedToCart.isNotEmpty,
              ),
            );
          }
        }

        // Create merchant VM
        final merchantVM = PostMerchantVM(
          id: merchant.id,
          bio: merchant.bio,
          name: merchant.username,
          profileImage: merchant.profileImage,
          username: merchant.username,
          rating: (merchant.rating * 100).truncate() / 100,
        );

        // Calculate likes and saves for this post
        final likesCount = postLikes
            .where((like) => like.postId == post.id)
            .length;
        final savesCount = postSaves
            .where((save) => save.postId == post.id)
            .length;
        final isLiked = postLikes.any(
          (like) => like.postId == post.id && like.userId == currentUserId,
        );
        final isSaved = postSaves.any(
          (save) => save.postId == post.id && save.userId == currentUserId,
        );

        return PostVM.fromRaw(
          post,
          merchant: merchantVM,
          products: postProducts,
          likesCount: likesCount,
          savesCount: savesCount,
          isLiked: isLiked,
          isSaved: isSaved,
        );
      }),
    );

    return enrichedPosts;
  }

  // Helper method to get posts filtered by category
  Future<List<PostModel>> _getPostsByCategory(
    ProductCategory category,
    int limit,
  ) async {
    try {
      // First, get the category ID from the database
      final categoryStatement = Clauses.where.eq(
        Tables.productCategories.cols.name,
        category.name,
      );
      final categoryModels = await _productCategoryRepository.queryThisTable(
        where: categoryStatement.clause,
        args: categoryStatement.args,
      );

      if (categoryModels.isEmpty) {
        return []; // No category found, return empty list
      }

      final categoryId = categoryModels.first.id;

      // Get all products in this category
      final categoryMapsStatement = Clauses.where.eq(
        Tables.productCategoryMaps.cols.categoryId,
        categoryId,
      );
      final categoryMaps = await _productCategoryMapsRepository.queryThisTable(
        where: categoryMapsStatement.clause,
        args: categoryMapsStatement.args,
      );

      if (categoryMaps.isEmpty) {
        return []; // No products in this category
      }

      final productIds = categoryMaps.map((map) => map.productId).toList();

      // Get all post-product relationships for these products
      final posts = <PostModel>[];
      final addedPostIds = <int>{};

      for (final productId in productIds) {
        final postProductStatement = Clauses.where.eq(
          Tables.postProducts.cols.productId,
          productId,
        );
        final postProductRelations = await _postProductsRepository
            .queryThisTable(
              where: postProductStatement.clause,
              args: postProductStatement.args,
            );

        for (final relation in postProductRelations) {
          // Avoid duplicate posts
          if (!addedPostIds.contains(relation.postId)) {
            final post = await _postRepository.getById(relation.postId);
            if (post != null) {
              posts.add(post);
              addedPostIds.add(relation.postId);

              // Stop if we've reached the limit
              if (posts.length >= limit) {
                return posts;
              }
            }
          }
        }
      }

      return posts;
    } catch (e) {
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get posts by category: ${e.toString()}',
      );
    }
  }
}
