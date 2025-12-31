part of domain;

class CreateProductCategoryDTO {
  final String name;

  CreateProductCategoryDTO({required this.name});
}

class UpdateProductCategoryDTO {
  final String? name;

  UpdateProductCategoryDTO({this.name});
}
