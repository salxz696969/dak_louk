import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/live_stream_product_repo.dart';
import 'package:dak_louk/data/repositories/product_media_repo.dart';
import 'package:dak_louk/data/repositories/product_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class LiveStreamProductsService {
  late final currentMerchantId;
  final LiveStreamProductRepository _liveStreamProductRepository =
      LiveStreamProductRepository();
  final ProductRepository _productRepository = ProductRepository();
  final ProductMediaRepository _productMediaRepository =
      ProductMediaRepository();

  LiveStreamProductsService() {
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

  Future<List<LiveStreamProductsVM>> getLiveStreamProductsByLiveStreamId(
    int liveStreamId,
  ) async {
    try {
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

        final imageUrl = productMediaList.isNotEmpty
            ? productMediaList.first.url
            : '';

        vmList.add(
          LiveStreamProductsVM.fromRaw(
            liveStreamProduct,
            image: imageUrl,
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

  Future<LiveStreamProductsVM?> createLiveStreamProduct(
    String dto, // to change
  ) async {
    // Placeholder - implement later
    throw UnimplementedError('createLiveStreamProduct not implemented');
  }

  Future<LiveStreamProductsVM?> updateLiveStreamProduct(
    int id,
    String dto, // to change
  ) async {
    // Placeholder - implement later
    throw UnimplementedError('updateLiveStreamProduct not implemented');
  }

  Future<void> deleteLiveStreamProduct(int id) async {
    // Placeholder - implement later
    throw UnimplementedError('deleteLiveStreamProduct not implemented');
  }
}
