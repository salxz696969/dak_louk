import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/product_repo.dart';
import 'package:dak_louk/data/repositories/product_media_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ProductService {
  late final currentUserId;
  final ProductRepository _productRepository = ProductRepository();
  final ProductMediaRepository _productMediaRepository =
      ProductMediaRepository();

  ProductService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  // Migrated from ProductDao
  Future<List<ProductVM>> getAllProducts(String? category, int limit) async {
    try {
      if (limit <= 0) limit = 100;
      if (category == null) {
        final products = await _productRepository.queryThisTable(limit: limit);
        if (products.isNotEmpty) {
          return products.map((product) => ProductVM.fromRaw(product)).toList();
        }
        throw AppError(type: ErrorType.NOT_FOUND, message: 'No products found');
      }
      if (category == 'all') {
        final products = await _productRepository.queryThisTable(limit: limit);
        if (products.isNotEmpty) {
          return products.map((product) => ProductVM.fromRaw(product)).toList();
        }
        throw AppError(type: ErrorType.NOT_FOUND, message: 'No products found');
      } else {
        final statement = Clauses.where.eq(
          Tables.productCategories.cols.name,
          category,
        );
        final products = await _productRepository.queryThisTable(
          where: statement.clause,
          args: statement.args,
          limit: limit,
        );
        if (products.isNotEmpty) {
          return products.map((product) => ProductVM.fromRaw(product)).toList();
        }
        throw AppError(type: ErrorType.NOT_FOUND, message: 'No products found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductVM>> getAllProductsForCurrentMerchant() async {
    try {
      final statement = Clauses.where.eq(
        Tables.products.cols.merchantId,
        currentUserId,
      );

      final products = await _productRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.products.cols.createdAt).clause,
      );

      if (products.isEmpty) {
        return [];
      }

      final List<ProductVM> productsWithMedia = [];

      for (final product in products) {
        final mediaStatement = Clauses.where.eq(
          Tables.productMedias.cols.productId,
          product.id,
        );

        final medias = await _productMediaRepository.queryThisTable(
          where: mediaStatement.clause,
          args: mediaStatement.args,
        );

        final mediaUrls = medias.isNotEmpty
            ? medias.map((media) => media.url).toList()
            : <String>[];

        final productVM = ProductVM.fromRaw(product, mediaUrls: mediaUrls);
        productsWithMedia.add(productVM);
      }
      return productsWithMedia;
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

  // Basic CRUD operations
  Future<ProductVM?> createProduct(CreateProductDTO dto) async {
    try {
      final productModel = ProductModel(
        id: 0,
        merchantId: currentUserId,
        name: dto.name,
        description: dto.description,
        price: dto.price,
        quantity: dto.quantity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await _productRepository.insert(productModel);
      if (id > 0) {
        final newProduct = await _productRepository.getById(id);
        if (newProduct != null) {
          return ProductVM.fromRaw(newProduct);
        }
        throw AppError(type: ErrorType.NOT_FOUND, message: 'Product not found');
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create product',
      );
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create product',
      );
    }
  }

  Future<ProductVM?> getProductById(int id) async {
    try {
      final product = await _productRepository.getById(id);
      if (product != null) {
        return ProductVM.fromRaw(product);
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'Product not found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get product',
      );
    }
  }

  Future<ProductVM?> updateProduct(int id, UpdateProductDTO dto) async {
    try {
      final product = await _productRepository.getById(id);
      if (product == null) {
        throw AppError(type: ErrorType.NOT_FOUND, message: 'Product not found');
      }
      if (product.merchantId != currentUserId) {
        throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
      }
      final productModel = ProductModel(
        id: id,
        merchantId: currentUserId,
        name: dto.name ?? product.name,
        description: dto.description ?? product.description,
        price: dto.price ?? product.price,
        quantity: dto.quantity ?? product.quantity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _productRepository.update(productModel);
      final newProduct = await _productRepository.getById(id);
      if (newProduct != null) {
        return ProductVM.fromRaw(newProduct);
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'Product not found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to update product',
      );
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final product = await _productRepository.getById(productId);
      if (product == null) {
        throw AppError(type: ErrorType.NOT_FOUND, message: 'Product not found');
      }
      if (product.merchantId != currentUserId) {
        throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
      }
      await _productRepository.delete(productId);
      throw AppError(type: ErrorType.NOT_FOUND, message: 'Product not found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to delete product',
      );
    }
  }
}
