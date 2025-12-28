import 'package:dak_louk/db/repositories/repository_base.dart';
import 'package:dak_louk/db/repositories/product_dao.dart';
import 'package:dak_louk/db/repositories/user_dao.dart';
import 'package:dak_louk/models/post_model.dart';
import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/models/user_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class PostDao extends BaseRepository<PostModel> {
  @override
  String get tableName => Tables.posts.tableName;

  @override
  PostModel fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map[Tables.posts.cols.id] as int,
      userId: map[Tables.posts.cols.userId] as int,
      title: map[Tables.posts.cols.title] as String,
      productId: map[Tables.posts.cols.productId] as int,
      createdAt: DateTime.parse(map[Tables.posts.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.posts.cols.updatedAt] as String),
      product: null,
      user: null,
      images: null,
    );
  }

  @override
  Map<String, dynamic> toMap(PostModel model) {
    return {
      Tables.posts.cols.id: model.id,
      Tables.posts.cols.userId: model.userId,
      Tables.posts.cols.title: model.title,
      Tables.posts.cols.productId: model.productId,
      Tables.posts.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.posts.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }

  Future<List<PostModel>> getPostsByUserId(int userId, int limit) async {
    try {
      final statement = Clauses.where.eq(Tables.posts.cols.userId, userId);
      return await queryThisTable(
        where: statement.clause,
        args: statement.args,
        limit: limit > 0 ? limit : 20,
      );
    } catch (e) {
      rethrow;
    }
  }
}
