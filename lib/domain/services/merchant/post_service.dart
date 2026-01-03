import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
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
  late final currentMerchantId;
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

  // Business logic methods migrated from PostRepository
  PostService() {
    if (AppSession.instance.isLoggedIn &&
        AppSession.instance.merchantId != null) {
      currentMerchantId = AppSession.instance.merchantId;
    } else {
      throw AppError(
        type: ErrorType.UNAUTHORIZED,
        message: 'Unauthorized - No merchant session',
      );
    }
  }

  Future<List<PostVM>> getAllPosts({
    ProductCategory category = ProductCategory.all,
    int limit = 100,
  }) async {
    try {
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
                  imageUrls: productMedias.map((media) => media.url).toList(),
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
            (like) =>
                like.postId == post.id && like.userId == currentMerchantId,
          );
          final isSaved = postSaves.any(
            (save) =>
                save.postId == post.id && save.userId == currentMerchantId,
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

  // Basic CRUD operations
  Future<PostVM?> createPost(CreatePostDTO dto) async {
    try {
      final id = await _postRepository.insert(
        PostModel(
          id: 0,
          merchantId: currentMerchantId,
          caption: dto.caption,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final newPost = await _postRepository.getById(id);
      if (newPost != null) {
        final postVMs = await _buildPostVMs([newPost]);
        return postVMs.isNotEmpty ? postVMs.first : null;
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
      final post = await _postRepository.getById(id);
      if (post != null) {
        final postVMs = await _buildPostVMs([post]);
        return postVMs.isNotEmpty ? postVMs.first : null;
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
      if (post.merchantId != currentMerchantId) {
        throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
      }
      await _postRepository.update(
        PostModel(
          id: id,
          merchantId: currentMerchantId,
          caption: dto.caption,
          createdAt: post.createdAt, // Keep original creation time
          updatedAt: DateTime.now(),
        ),
      );
      final updatedPost = await _postRepository.getById(id);
      if (updatedPost != null) {
        final postVMs = await _buildPostVMs([updatedPost]);
        return postVMs.isNotEmpty ? postVMs.first : null;
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
                imageUrls: productMedias.map((media) => media.url).toList(),
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
          (like) => like.postId == post.id && like.userId == currentMerchantId,
        );
        final isSaved = postSaves.any(
          (save) => save.postId == post.id && save.userId == currentMerchantId,
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
