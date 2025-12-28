import 'package:dak_louk/utils/schema/tables.dart';

class ReviewsTable implements DbTable<ReviewsCols> {
  const ReviewsTable();
  @override
  String get tableName => 'reviews';
  @override
  ReviewsCols get cols => ReviewsCols();
}

class ReviewsCols extends BaseCols {
  const ReviewsCols();
  static const String userIdCol = 'user_id';
  static const String targetUserIdCol = 'target_user_id';
  static const String textCol = 'text';
  static const String ratingCol = 'rating';

  String get targetUserId => targetUserIdCol;
  String get text => textCol;
  String get rating => ratingCol;
}
