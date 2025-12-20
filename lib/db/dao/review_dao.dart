import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/review_model.dart';
import 'package:dak_louk/models/user_model.dart';

class ReviewDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertReview(Review review) async {
    final db = await _appDatabase.database;
    return await db.insert('reviews', review.toMap());
  }

  Future<Review> getReviewById(int id) async {
    final db = await _appDatabase.database;
    final result = await db.query('reviews', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final map = result.first;
      final UserDao userDao = UserDao();
      final User user = await userDao.getUserById(map['user_id'] as int);
      final User targetUser = await userDao.getUserById(
        map['target_user_id'] as int,
      );
      return Review.fromMap(map, user, targetUser);
    }
    throw Exception('Review not found');
  }

  Future<List<Review>> getReviewsByTargetUserId(User targetUser) async {
    final db = await _appDatabase.database;
    final result = await db.query(
      'reviews',
      where: 'target_user_id = ?',
      whereArgs: [targetUser.id],
    );
    List<Review> reviews = [];
    for (var map in result) {
      reviews.add(Review.fromMap(map, null, targetUser));
    }
    return reviews;
  }

  Future<int> updateReview(Review review) async {
    final db = await _appDatabase.database;
    return await db.update(
      'reviews',
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );
  }

  Future<int> deleteReview(int id) async {
    final db = await _appDatabase.database;
    return await db.delete('reviews', where: 'id = ?', whereArgs: [id]);
  }
}
