part of domain;

class PostProductModel extends Cacheable {
  final int id;
  final int postId;
  final int productId;

  PostProductModel({
    required this.id,
    required this.postId,
    required this.productId,
  });
}
