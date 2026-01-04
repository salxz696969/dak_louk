import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_model.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/live_stream_product_repo.dart';
import 'package:dak_louk/data/repositories/product_media_repo.dart';
import 'package:dak_louk/data/repositories/product_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/data/cache/cache.dart';

class LiveStreamProductsService {
  late final currentUserId;
  final LiveStreamProductRepository _liveStreamProductRepository =
      LiveStreamProductRepository();
  final ProductRepository _productRepository = ProductRepository();
  final ProductMediaRepository _productMediaRepository =
      ProductMediaRepository();
  final Cache _cache = Cache();
  late final String _baseCacheKey;

  LiveStreamProductsService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
      _baseCacheKey = 'service:user:$currentUserId:live_stream_products';
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  Future<List<LiveStreamProductsVM>> getLiveStreamProductsByLiveStreamId(
    int liveStreamId,
  ) async {
    try {
      final cacheKey =
          '$_baseCacheKey:getLiveStreamProductsByLiveStreamId:$liveStreamId';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _cache.expectMany(cached).cast<LiveStreamProductsVM>().toList();
      }

      final statement = Clauses.where.eq(
        Tables.liveStreamProducts.cols.liveStreamId,
        liveStreamId,
      );
      final liveStreamProducts = await _liveStreamProductRepository
          .queryThisTable(where: statement.clause, args: statement.args);

      if (liveStreamProducts.isEmpty) {
        throw AppError(
          type: ErrorType.NOT_FOUND,
          message: 'No live stream products found',
        );
      }

      List<LiveStreamProductsVM> vmList = [];

      for (final liveStreamProduct in liveStreamProducts) {
        // Fetch the corresponding product using the productId from live stream product
        final product = await _productRepository.getById(
          liveStreamProduct.productId,
        );
        if (product == null) {
          // If product not found, skip this entry or throw depending on use-case
          continue;
        }

        // Fetch product media for the product
        final productMediaList = await _productMediaRepository.queryThisTable(
          where: Clauses.where
              .eq(Tables.productMedias.cols.productId, product.id)
              .clause,
          args: Clauses.where
              .eq(Tables.productMedias.cols.productId, product.id)
              .args,
        );

        final medias = productMediaList.isNotEmpty
            ? productMediaList
                  .map(
                    (m) => MediaModel(
                      url: m.url,
                      type: m.mediaType == 'video'
                          ? MediaType.video
                          : MediaType.image,
                    ),
                  )
                  .toList()
            : <MediaModel>[];

        vmList.add(
          LiveStreamProductsVM.fromRaw(
            liveStreamProduct,
            medias: medias,
            name: product.name,
            quantity: product.quantity,
            price: (product.price * 100).truncate() / 100,
          ),
        );
      }

      if (vmList.isEmpty) {
        throw AppError(
          type: ErrorType.NOT_FOUND,
          message: 'No live stream products found',
        );
      }

      _cache.set(cacheKey, Many(vmList));
      return vmList;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get live stream products',
      );
    }
  }
}
