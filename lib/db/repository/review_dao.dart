import 'package:dak_louk/utils/db/app_database.dart';
import 'package:dak_louk/db/repository/user_dao.dart';
import 'package:dak_louk/models/review_model.dart';
import 'package:dak_louk/models/user_model.dart';

class ReviewDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertReview(ReviewModel review) async {
    try {
      final db = await _appDatabase.database;
      final map = review.toMap();
      map.remove('id');
      return await db.insert('reviews', map);
    } catch (e) {
      rethrow;
    }
  }

  Future<ReviewModel> getReviewById(int id) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'reviews',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        final map = result.first;
        final UserDao userDao = UserDao();
        final UserModel user = await userDao.getUserById(map['user_id'] as int);
        final UserModel targetUser = await userDao.getUserById(
          map['target_user_id'] as int,
        );
        return ReviewModel.fromMap(map, user, targetUser);
      }
      throw Exception('Review not found');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReviewModel>> getReviewsByTargetUserId(
    UserModel targetUser,
  ) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'reviews',
        where: 'target_user_id = ?',
        whereArgs: [targetUser.id],
      );
      List<ReviewModel> reviews = [];
      for (var map in result) {
        reviews.add(ReviewModel.fromMap(map, null, targetUser));
      }
      return reviews;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateReview(ReviewModel review) async {
    try {
      final db = await _appDatabase.database;
      return await db.update(
        'reviews',
        review.toMap(),
        where: 'id = ?',
        whereArgs: [review.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteReview(int id) async {
    try {
      final db = await _appDatabase.database;
      return await db.delete('reviews', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }
}
