import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/domain/models/index.dart';

class ReviewRepository extends BaseRepository<ReviewModel> {
  @override
  String get tableName => Tables.reviews.tableName;

  @override
  ReviewModel fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map[Tables.reviews.cols.id] as int,
      userId: map[Tables.reviews.cols.userId] as int,
      merchantId: map[Tables.reviews.cols.merchantId] as int,
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
      Tables.reviews.cols.merchantId: model.merchantId,
      Tables.reviews.cols.text: model.text,
      Tables.reviews.cols.rating: model.rating,
    };
  }
}
