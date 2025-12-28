import 'package:dak_louk/db/repositories/product_repo.dart';
import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class ProductService {
  final ProductRepository _productRepository = ProductRepository();

  // Business logic methods migrated from ProductRepository
  Future<List<ProductModel>> getAllProductsByLiveStreamId(
    int liveStreamId,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.products.cols.liveStreamId,
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
        Tables.products.cols.category,
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

  Future<List<ProductModel>> getProductsByUserId(int userId) async {
    try {
      final statement = Clauses.where.eq(Tables.products.cols.userId, userId);
      return await _productRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Additional business logic
  Future<List<ProductModel>> searchProducts(String searchTerm) async {
    try {
      final titleStatement = Clauses.like.like(
        Tables.products.cols.title,
        searchTerm,
      );
      final descStatement = Clauses.like.like(
        Tables.products.cols.description,
        '%$searchTerm%',
      );

      // Search by title
      final titleResults = await _productRepository.queryThisTable(
        where: titleStatement.clause,
        args: titleStatement.args,
      );

      // Search by description
      final descResults = await _productRepository.queryThisTable(
        where: descStatement.clause,
        args: descStatement.args,
      );

      // Combine and remove duplicates
      final allResults = <ProductModel>[];
      allResults.addAll(titleResults);

      for (final product in descResults) {
        if (!allResults.any((p) => p.id == product.id)) {
          allResults.add(product);
        }
      }

      return allResults;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      final statement = Clauses.where.between(
        Tables.products.cols.price,
        minPrice,
        maxPrice,
      );
      return await _productRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getAvailableProducts() async {
    try {
      final statement = Clauses.where.gt(Tables.products.cols.quantity, 0);
      return await _productRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isProductAvailable(int productId, int requestedQuantity) async {
    try {
      final product = await _productRepository.getById(productId);
      return product.quantity >= requestedQuantity;
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductModel> updateProductQuantity(
    int productId,
    int newQuantity,
  ) async {
    try {
      final product = await _productRepository.getById(productId);
      final updatedProduct = ProductModel(
        id: product.id,
        userId: product.userId,
        title: product.title,
        description: product.description,
        category: product.category,
        price: product.price,
        quantity: newQuantity,
        createdAt: product.createdAt,
        updatedAt: DateTime.now(),
        image: product.image,
      );

      await _productRepository.update(updatedProduct);
      return updatedProduct;
    } catch (e) {
      rethrow;
    }
  }

  // Basic CRUD operations
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final id = await _productRepository.insert(product);
      return await _productRepository.getById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductModel> getProductById(int id) async {
    try {
      return await _productRepository.getById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      await _productRepository.update(product);
      return await _productRepository.getById(product.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await _productRepository.delete(productId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    try {
      return await _productRepository.getAll();
    } catch (e) {
      rethrow;
    }
  }
}
