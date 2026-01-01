part of domain;

class ProductCategoryMapModel extends Cacheable {
  final int id;
  final int productId;
  final int categoryId;

  ProductCategoryMapModel({
    required this.id,
    required this.productId,
    required this.categoryId,
  });
}
