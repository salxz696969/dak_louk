import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/domain/models/models.dart';

class PostProductsRepository extends BaseRepository<PostProductModel> {
  @override
  String get tableName => Tables.postProducts.tableName;

  @override
  PostProductModel fromMap(Map<String, dynamic> map) {
    return PostProductModel(
      id: map[Tables.postProducts.cols.id] as int,
      postId: map[Tables.postProducts.cols.postId] as int,
      productId: map[Tables.postProducts.cols.productId] as int,
    );
  }

  @override
  Map<String, dynamic> toMap(PostProductModel model) {
    return {
      Tables.postProducts.cols.id: model.id,
      Tables.postProducts.cols.postId: model.postId,
      Tables.postProducts.cols.productId: model.productId,
    };
  }
}
