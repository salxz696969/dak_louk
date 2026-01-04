import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/cart_repo.dart';
import 'package:dak_louk/data/repositories/live_stream_repo.dart';
import 'package:dak_louk/data/repositories/merchant_repo.dart';
import 'package:dak_louk/data/repositories/product_repo.dart';
import 'package:dak_louk/data/repositories/product_media_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/repositories/post_repo.dart';
import 'package:dak_louk/data/repositories/promo_media_repo.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/data/cache/cache.dart';

class MerchantService {
  late final currentUserId;
  final MerchantRepository _merchantRepository = MerchantRepository();
  final PostRepository _postRepository = PostRepository();
  final PromoMediaRepository _promoMediaRepository = PromoMediaRepository();
  final LiveStreamRepository _liveStreamRepository = LiveStreamRepository();
  final ProductRepository _productRepository = ProductRepository();
  final ProductMediaRepository _productMediaRepository =
      ProductMediaRepository();
  final CartRepository _cartRepository = CartRepository();
  final Cache _cache = Cache();
  late final String _baseCacheKey;

  MerchantService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
      _baseCacheKey = 'service:user:$currentUserId:merchant';
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  Future<MerchantVM> getMerchantById(int id) async {
    try {
      final cacheKey = '$_baseCacheKey:getMerchantById:$id';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectSingle(cached) as MerchantVM;
      }

      final merchant = await _merchantRepository.getById(id);
      if (merchant == null) {
        throw AppError(
          type: ErrorType.NOT_FOUND,
          message: 'Merchant not found',
        );
      }
      final result = MerchantVM.fromRaw(merchant);
      _cache.set(cacheKey, Single(result));
      return result;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get merchant',
      );
    }
  }

  Future<List<MerchantPostsVM>> getMerchantPosts(int merchantId) async {
    try {
      final cacheKey = '$_baseCacheKey:getMerchantPosts:$merchantId';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectMany(cached).cast<MerchantPostsVM>().toList();
      }

      final posts = await _postRepository.queryThisTable(
        where: Clauses.where
            .eq(Tables.posts.cols.merchantId, merchantId)
            .clause,
        args: Clauses.where.eq(Tables.posts.cols.merchantId, merchantId).args,
      );

      final List<MerchantPostsVM> result = [];

      for (final post in posts) {
        final medias = await _promoMediaRepository.queryThisTable(
          where: Clauses.where
              .eq(Tables.promoMedias.cols.postId, post.id)
              .clause,
          args: Clauses.where.eq(Tables.promoMedias.cols.postId, post.id).args,
        );

        result.add(MerchantPostsVM.fromRaw(post, promoMedias: medias));
      }

      _cache.set(cacheKey, Many(result));
      return result;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get merchant posts',
      );
    }
  }

  Future<List<MerchantLivestreamsVM>> getMerchantLiveStreams(
    int merchantId,
  ) async {
    try {
      final cacheKey = '$_baseCacheKey:getMerchantLiveStreams:$merchantId';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectMany(cached).cast<MerchantLivestreamsVM>().toList();
      }

      final liveStreams = await _liveStreamRepository.queryThisTable(
        where: Clauses.where
            .eq(Tables.liveStreams.cols.merchantId, merchantId)
            .clause,
        args: Clauses.where
            .eq(Tables.liveStreams.cols.merchantId, merchantId)
            .args,
      );
      // No media join needed for livestreams per instructions
      final result = liveStreams
          .map(
            (stream) => MerchantLivestreamsVM.fromRaw(stream, promoMedias: []),
          )
          .toList();

      _cache.set(cacheKey, Many(result));
      return result;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get merchant live streams',
      );
    }
  }

  Future<List<MerchantProductsVM>> getMerchantProducts(int merchantId) async {
    try {
      final cacheKey = '$_baseCacheKey:getMerchantProducts:$merchantId';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectMany(cached).cast<MerchantProductsVM>().toList();
      }

      final products = await _productRepository.queryThisTable(
        where: Clauses.where
            .eq(Tables.products.cols.merchantId, merchantId)
            .clause,
        args: Clauses.where
            .eq(Tables.products.cols.merchantId, merchantId)
            .args,
      );

      final isAddedToCart = await _cartRepository.queryThisTable(
        where: Clauses.where
            .eq(
              Tables.carts.cols.productId,
              products.map((product) => product.id).toList(),
            )
            .clause,
        args: Clauses.where
            .eq(
              Tables.carts.cols.productId,
              products.map((product) => product.id).toList(),
            )
            .args,
      );
      final List<MerchantProductsVM> result = [];

      for (final product in products) {
        final medias = await _productMediaRepository.queryThisTable(
          where: Clauses.where
              .eq(Tables.productMedias.cols.productId, product.id)
              .clause,
          args: Clauses.where
              .eq(Tables.productMedias.cols.productId, product.id)
              .args,
        );

        final mediaVMs = medias.map(ProductMediaVM.fromRaw).toList();

        result.add(
          MerchantProductsVM.fromRaw(
            product,
            productMedias: mediaVMs,
            isAddedToCart: isAddedToCart.isNotEmpty,
          ),
        );
      }

      _cache.set(cacheKey, Many(result));
      return result;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get merchant products',
      );
    }
  }
}
