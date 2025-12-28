import 'package:dak_louk/db/repositories/repository_base.dart';
import 'package:dak_louk/models/review_model.dart';
import 'package:dak_louk/models/user_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class ReviewDao extends BaseRepository<ReviewModel> {
  @override
  String get tableName => Tables.reviews.tableName;

  @override
  ReviewModel fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map[Tables.reviews.cols.id] as int,
      userId: map[Tables.reviews.cols.userId] as int,
      targetUserId: map[Tables.reviews.cols.targetUserId] as int,
      text: map[Tables.reviews.cols.text] as String,
      rating: map[Tables.reviews.cols.rating] as double,
      createdAt: DateTime.parse(map[Tables.reviews.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.reviews.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(ReviewModel model) {
    return {
      Tables.reviews.cols.id: model.id,
      Tables.reviews.cols.userId: model.userId,
      Tables.reviews.cols.targetUserId: model.targetUserId,
      Tables.reviews.cols.text: model.text,
      Tables.reviews.cols.rating: model.rating,
    };
  }

  Future<List<ReviewModel>> getReviewsByTargetUserId(
    UserModel targetUser,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.reviews.cols.targetUserId,
        targetUser.id,
      );
      final reviews = await queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
      if (reviews.isNotEmpty) {
        return reviews;
      }
      throw Exception('Reviews not found');
    } catch (e) {
      rethrow;
    }
  }
}
