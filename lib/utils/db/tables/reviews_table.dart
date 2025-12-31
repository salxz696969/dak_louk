import 'package:dak_louk/utils/db/tables/tables.dart';

class ReviewsTable implements DbTable<ReviewsCols> {
  const ReviewsTable();
  @override
  String get tableName => 'reviews';
  @override
  ReviewsCols get cols => ReviewsCols();
}

// Note: Reviews table only has created_at, not updated_at
class ReviewsCols extends BaseColsCreatedOnly {
  const ReviewsCols();
  static const String userIdCol = 'user_id';
  static const String merchantIdCol = 'merchant_id';
  static const String textCol = 'text';
  static const String ratingCol = 'rating';

  String get userId => userIdCol;
  String get merchantId => merchantIdCol;
  String get text => textCol;
  String get rating => ratingCol;
}
