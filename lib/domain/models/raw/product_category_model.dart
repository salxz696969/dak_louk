part of models;

class ProductCategoryModel extends Cacheable {
  final int id;
  final String name;

  ProductCategoryModel({required this.id, required this.name});
}
