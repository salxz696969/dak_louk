import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/live_stream_product_repo.dart';
import 'package:dak_louk/data/repositories/live_stream_repo.dart';
import 'package:dak_louk/data/repositories/live_stream_chat_repo.dart';
import 'package:dak_louk/data/repositories/product_repo.dart';
import 'package:dak_louk/data/repositories/product_media_repo.dart';
import 'package:dak_louk/data/cache/cache.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class LiveStreamService {
  late final currentMerchantId;
  final LiveStreamRepository _liveStreamRepository = LiveStreamRepository();
  final LiveStreamChatRepository _liveStreamChatRepository =
      LiveStreamChatRepository();
  final LiveStreamProductRepository _liveStreamProductRepository =
      LiveStreamProductRepository();
  final ProductRepository _productRepository = ProductRepository();
  final ProductMediaRepository _productMediaRepository =
      ProductMediaRepository();
  final Cache _cache = Cache();
  late final String _baseCacheKey;
  late final String userSideCacheKeyPattern;

  LiveStreamService() {
    if (AppSession.instance.isLoggedIn &&
        AppSession.instance.merchantId != null) {
      currentMerchantId = AppSession.instance.merchantId;
      _baseCacheKey = 'service:merchant:$currentMerchantId:live_stream';
      userSideCacheKeyPattern = 'service:user:*:live_stream:*';
    } else {
      throw AppError(
        type: ErrorType.UNAUTHORIZED,
        message: 'Unauthorized - No merchant session',
      );
    }
  }

  Future<List<MerchantLiveStreamsVM>> getAllLiveStreams() async {
    try {
      final cacheKey = '$_baseCacheKey:getAllLiveStreams';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectMany(cached).cast<MerchantLiveStreamsVM>().toList();
      }
      final statement = Clauses.where.eq(
        Tables.liveStreams.cols.merchantId,
        currentMerchantId,
      );

      // Get all live streams for the merchant
      final liveStreams = await _liveStreamRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.liveStreams.cols.createdAt).clause,
      );

      // Get all live stream products and their associated products
      final liveStreamsWithProducts = <MerchantLiveStreamsVM>[];

      for (final liveStream in liveStreams) {
        // Get products for this live stream
        final liveStreamProducts = await _liveStreamProductRepository
            .queryThisTable(
              where: Clauses.where
                  .eq(
                    Tables.liveStreamProducts.cols.liveStreamId,
                    liveStream.id,
                  )
                  .clause,
              args: Clauses.where
                  .eq(
                    Tables.liveStreamProducts.cols.liveStreamId,
                    liveStream.id,
                  )
                  .args,
            );

        // Get product details for each live stream product
        final products = <MerchantLiveStreamsProductsVM>[];
        for (final liveStreamProduct in liveStreamProducts) {
          final product = await _productRepository.queryThisTable(
            where: Clauses.where
                .eq(Tables.products.cols.id, liveStreamProduct.productId)
                .clause,
            args: Clauses.where
                .eq(Tables.products.cols.id, liveStreamProduct.productId)
                .args,
          );

          if (product.isNotEmpty) {
            final productModel = product.first;
            // Get product media
            final productMedia = await _productMediaRepository.queryThisTable(
              where: Clauses.where
                  .eq(Tables.productMedias.cols.productId, productModel.id)
                  .clause,
              args: Clauses.where
                  .eq(Tables.productMedias.cols.productId, productModel.id)
                  .args,
            );

            final imageUrls = productMedia.isNotEmpty
                ? productMedia.map((media) => media.url).toList()
                : <String>[];

            products.add(
              MerchantLiveStreamsProductsVM.fromRaw(
                liveStreamProduct,
                name: productModel.name,
                price: productModel.price,
                quantity: productModel.quantity,
                imageUrls: imageUrls,
              ),
            );
          }
        }

        liveStreamsWithProducts.add(
          MerchantLiveStreamsVM.fromRaw(liveStream, products: products),
        );
      }

      _cache.set(cacheKey, Many(liveStreamsWithProducts));
      return liveStreamsWithProducts;
    } catch (e) {
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get all live streams',
      );
    }
  }

  Future<MerchantLiveStreamsVM?> getLiveStreamById(int id) async {
    try {
      final cacheKey = '$_baseCacheKey:getLiveStreamById:$id';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectSingle(cached) as MerchantLiveStreamsVM;
      }
      final liveStream = await _liveStreamRepository.getById(id);
      if (liveStream != null && liveStream.merchantId == currentMerchantId) {
        _cache.set(cacheKey, Single(MerchantLiveStreamsVM.fromRaw(liveStream)));
        return MerchantLiveStreamsVM.fromRaw(liveStream);
      }
      return null;
    } catch (e) {
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get live stream',
      );
    }
  }

  // Basic CRUD operations
  Future<MerchantLiveStreamsVM?> createLiveStream(
    CreateLiveStreamDTO dto,
  ) async {
    try {
      final liveStreamModel = LiveStreamModel(
        id: 0,
        merchantId: currentMerchantId,
        title: dto.title,
        streamUrl: dto.streamUrl,
        thumbnailUrl: dto.thumbnailUrl,
        viewCount: 0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      final id = await _liveStreamRepository.insert(liveStreamModel);
      // Add products if provided
      if (dto.productIds != null && dto.productIds!.isNotEmpty) {
        for (final productId in dto.productIds!) {
          await _liveStreamProductRepository.insert(
            LiveStreamProductModel(
              id: 0,
              liveStreamId: id,
              productId: productId,
            ),
          );
        }
      }

      final newLiveStream = await _liveStreamRepository.getById(id);
      if (newLiveStream != null) {
        _cache.del('$_baseCacheKey:getLiveStreamById:$id');
        _cache.del('$_baseCacheKey:getAllLiveStreams');
        _cache.delByPattern(userSideCacheKeyPattern);
        return MerchantLiveStreamsVM.fromRaw(newLiveStream);
      }

      throw AppError(
        type: ErrorType.NOT_FOUND,
        message: 'Live stream not found',
      );
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create live stream',
      );
    }
  }

  Future<MerchantLiveStreamsVM?> updateLiveStream(
    int id,
    UpdateLiveStreamDTO dto,
  ) async {
    try {
      final liveStream = await _liveStreamRepository.getById(id);
      if (liveStream == null || liveStream.merchantId != currentMerchantId) {
        return null;
      }

      final liveStreamModel = LiveStreamModel(
        id: id,
        merchantId: liveStream.merchantId,
        title: dto.title ?? liveStream.title,
        streamUrl: dto.streamUrl ?? liveStream.streamUrl,
        thumbnailUrl: dto.thumbnailUrl ?? liveStream.thumbnailUrl,
        viewCount: liveStream.viewCount,
        createdAt: liveStream.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _liveStreamRepository.update(liveStreamModel);

      // Delete old live stream products
      final oldProductsStatement = Clauses.where.eq(
        Tables.liveStreamProducts.cols.liveStreamId,
        id,
      );
      final oldProducts = await _liveStreamProductRepository.queryThisTable(
        where: oldProductsStatement.clause,
        args: oldProductsStatement.args,
      );
      for (final product in oldProducts) {
        await _liveStreamProductRepository.delete(product.id);
      }

      if (dto.productIds != null && dto.productIds!.isNotEmpty) {
        for (final productId in dto.productIds!) {
          await _liveStreamProductRepository.insert(
            LiveStreamProductModel(
              id: 0,
              liveStreamId: id,
              productId: productId,
            ),
          );
        }
      }

      final newLiveStream = await _liveStreamRepository.getById(id);
      if (newLiveStream != null) {
        _cache.del('$_baseCacheKey:getLiveStreamById:$id');
        _cache.del('$_baseCacheKey:getAllLiveStreams');
        _cache.delByPattern(userSideCacheKeyPattern);
        return MerchantLiveStreamsVM.fromRaw(newLiveStream);
      }
      throw AppError(
        type: ErrorType.NOT_FOUND,
        message: 'Live stream not found',
      );
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to update live stream',
      );
    }
  }

  Future<void> deleteLiveStream(int liveStreamId) async {
    try {
      final productStatement = Clauses.where.eq(
        Tables.liveStreamProducts.cols.liveStreamId,
        liveStreamId,
      );
      final products = await _liveStreamProductRepository.queryThisTable(
        where: productStatement.clause,
        args: productStatement.args,
      );

      for (final product in products) {
        await _liveStreamProductRepository.delete(product.id);
      }

      final chatStatement = Clauses.where.eq(
        Tables.liveStreamChats.cols.liveStreamId,
        liveStreamId,
      );
      final chats = await _liveStreamChatRepository.queryThisTable(
        where: chatStatement.clause,
        args: chatStatement.args,
      );

      for (final chat in chats) {
        await _liveStreamChatRepository.delete(chat.id);
      }

      // Delete the live stream
      await _liveStreamRepository.delete(liveStreamId);
      // delete all live stremas when deleting one, cuz we dont want leftover, could have looped to find it but cant access id since cacheble is vague
      // abit wasteful when doing getAllAgain
      // future fix maybe to let id be a field in cahceble and let teh child inherit from it, but sould cause issue if db is not named id or sth so for now each model define itself
      _cache.del('$_baseCacheKey:getLiveStreamById:$liveStreamId');
      _cache.del('$_baseCacheKey:getAllLiveStreams');
      _cache.delByPattern(userSideCacheKeyPattern);
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to delete live stream',
      );
    }
  }
}
