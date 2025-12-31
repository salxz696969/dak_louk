import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/product_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ProductService {
  late final currentUserId;
  final ProductRepository _productRepository = ProductRepository();

  ProductService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }
  // Business logic methods migrated from ProductRepository
  Future<List<ProductModel>> getAllProductsByLiveStreamId(
    int liveStreamId,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.liveStreamProducts.cols.liveStreamId,
        liveStreamId,
      );
      final result = await _productRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
      if (result.isNotEmpty) {
        return result;
      }
      throw Exception('No Products found');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final statement = Clauses.where.eq(
        Tables.productCategories.cols.name,
        category,
      );
      return await _productRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductVM>> getProductsByMerchantId(int merchantId) async {
    try {
      final products = await _productRepository.queryThisTable(
        where: Clauses.where
            .eq(Tables.products.cols.merchantId, merchantId)
            .clause,
      );
      if (products.isNotEmpty) {
        return products.map((product) => ProductVM.fromRaw(product)).toList();
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'No products found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get products',
      );
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

  // // Additional business logic
  // Future<List<ProductModel>> searchProducts(String searchTerm) async {
  //   try {
  //     final titleStatement = Clauses.like.like(
  //       Tables.products.cols.name,
  //       searchTerm,
  //     );
  //     final descStatement = Clauses.like.like(
  //       Tables.products.cols.description,
  //       '%$searchTerm%',
  //     );

  //     // Search by title
  //     final titleResults = await _productRepository.queryThisTable(
  //       where: titleStatement.clause,
  //       args: titleStatement.args,
  //     );

  //     // Search by description
  //     final descResults = await _productRepository.queryThisTable(
  //       where: descStatement.clause,
  //       args: descStatement.args,
  //     );

  //     // Combine and remove duplicates
  //     final allResults = <ProductModel>[];
  //     allResults.addAll(titleResults);

  //     for (final product in descResults) {
  //       if (!allResults.any((p) => p.id == product.id)) {
  //         allResults.add(product);
  //       }
  //     }

  //     return allResults;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<List<ProductModel>> getProductsByPriceRange(
  //   double minPrice,
  //   double maxPrice,
  // ) async {
  //   try {
  //     final statement = Clauses.where.between(
  //       Tables.products.cols.price,
  //       minPrice,
  //       maxPrice,
  //     );
  //     return await _productRepository.queryThisTable(
  //       where: statement.clause,
  //       args: statement.args,
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<List<ProductModel>> getAvailableProducts() async {
  //   try {
  //     final statement = Clauses.where.gt(Tables.products.cols.quantity, 0);
  //     return await _productRepository.queryThisTable(
  //       where: statement.clause,
  //       args: statement.args,
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<bool> isProductAvailable(int productId, int requestedQuantity) async {
  //   try {
  //     final product = await _productRepository.getById(productId);
  //     if (product == null) {
  //       return false;
  //     }
  //     return product.quantity >= requestedQuantity;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<ProductModel?> updateProductQuantity(
  //   int productId,
  //   int newQuantity,
  // ) async {
  //   try {
  //     final product = await _productRepository.getById(productId);
  //     if (product == null) {
  //       return null;
  //     }
  //     final updatedProduct = ProductModel(
  //       id: product.id,
  //       merchantId: product.merchantId,
  //       name: product.name,
  //       description: product.description,
  //       price: product.price,
  //       quantity: newQuantity,
  //       createdAt: product.createdAt,
  //       updatedAt: DateTime.now(),
  //     );

  //     await _productRepository.update(updatedProduct);
  //     final newProduct = await _productRepository.getById(productId);
  //     if (newProduct != null) {
  //       return newProduct;
  //     }
  //     return null;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

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

  // Future<List<ProductModel>> getAllProductsSimple() async {
  //   try {
  //     return await _productRepository.getAll();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}
