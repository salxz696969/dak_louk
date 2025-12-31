import 'package:dak_louk/data/repositories/review_repo.dart';
import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/domain/models/index.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ReviewService {
  final ReviewRepository _reviewRepository = ReviewRepository();
  final UserRepository _userRepository = UserRepository();

  // Business logic methods migrated from ReviewRepository
  Future<List<ReviewModel>> getReviewsByTargetUserId(
    UserModel targetUser,
  ) async {
    try {
      final statement = Clauses.where.eq(
        Tables.reviews.cols.targetUserId,
        targetUser.id,
      );
      final reviews = await _reviewRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.reviews.cols.createdAt).clause,
      );
      if (reviews.isNotEmpty) {
        return reviews;
      }
      throw Exception('Reviews not found');
    } catch (e) {
      rethrow;
    }
  }

  // Additional business logic methods
  Future<List<ReviewModel>> getReviewsByUserId(int userId) async {
    try {
      final statement = Clauses.where.eq(Tables.reviews.cols.userId, userId);
      return await _reviewRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.reviews.cols.createdAt).clause,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getAverageRatingForUser(int targetUserId) async {
    try {
      final statement = Clauses.where.eq(
        Tables.reviews.cols.targetUserId,
        targetUserId,
      );
      final reviews = await _reviewRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );

      if (reviews.isEmpty) {
        return 0.0;
      }

      final totalRating = reviews.fold<double>(
        0.0,
        (sum, review) => sum + review.rating,
      );
      return totalRating / reviews.length;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getReviewCountForUser(int targetUserId) async {
    try {
      final statement = Clauses.where.eq(
        Tables.reviews.cols.targetUserId,
        targetUserId,
      );
      final reviews = await _reviewRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
      return reviews.length;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReviewModel>> getReviewsByRating(double rating) async {
    try {
      final statement = Clauses.where.eq(Tables.reviews.cols.rating, rating);
      return await _reviewRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.reviews.cols.createdAt).clause,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReviewModel>> getReviewsByRatingRange(
    double minRating,
    double maxRating,
  ) async {
    try {
      final statement = Clauses.where.between(
        Tables.reviews.cols.rating,
        minRating,
        maxRating,
      );
      return await _reviewRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.reviews.cols.createdAt).clause,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReviewModel>> getRecentReviews({int limit = 20}) async {
    try {
      final orderByStmt = Clauses.orderBy.desc(Tables.reviews.cols.createdAt);
      return await _reviewRepository.queryThisTable(
        orderBy: orderByStmt.clause,
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReviewModel>> searchReviews(String searchTerm) async {
    try {
      final statement = Clauses.like.like(Tables.reviews.cols.text, searchTerm);
      return await _reviewRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.reviews.cols.createdAt).clause,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReviewModel?>> getReviewsWithUserInfo(int targetUserId) async {
    try {
      final targetUser = await _userRepository.getById(targetUserId);
      if (targetUser == null) {
        return [];
      }
      final reviews = await getReviewsByTargetUserId(targetUser);

      // Populate user information for each review
      final enrichedReviews = await Future.wait(
        reviews.map((review) async {
          final user = await _userRepository.getById(review.userId);
          final targetUser = await _userRepository.getById(review.targetUserId);
          if (user == null || targetUser == null) {
            return null;
          }
          return ReviewModel(
            id: review.id,
            userId: review.userId,
            targetUserId: review.targetUserId,
            rating: review.rating,
            text: review.text,
            createdAt: review.createdAt,
            updatedAt: review.updatedAt,
            user: user,
            targetUser: targetUser,
          );
        }),
      );

      return enrichedReviews;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasUserReviewedTarget(int userId, int targetUserId) async {
    try {
      final userStatement = Clauses.where.eq(
        Tables.reviews.cols.userId,
        userId,
      );
      final targetStatement = Clauses.where.eq(
        Tables.reviews.cols.targetUserId,
        targetUserId,
      );
      final combinedStatement = Clauses.where.and([
        userStatement,
        targetStatement,
      ]);

      final reviews = await _reviewRepository.queryThisTable(
        where: combinedStatement.clause,
        args: combinedStatement.args,
      );

      return reviews.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<ReviewModel?> getUserReviewForTarget(
    int userId,
    int targetUserId,
  ) async {
    try {
      final userStatement = Clauses.where.eq(
        Tables.reviews.cols.userId,
        userId,
      );
      final targetStatement = Clauses.where.eq(
        Tables.reviews.cols.targetUserId,
        targetUserId,
      );
      final combinedStatement = Clauses.where.and([
        userStatement,
        targetStatement,
      ]);

      final reviews = await _reviewRepository.queryThisTable(
        where: combinedStatement.clause,
        args: combinedStatement.args,
      );

      return reviews.isNotEmpty ? reviews.first : null;
    } catch (e) {
      rethrow;
    }
  }

  // Update user's overall rating after review changes
  Future<void> updateUserRating(int targetUserId) async {
    try {
      final averageRating = await getAverageRatingForUser(targetUserId);
      final targetUser = await _userRepository.getById(targetUserId);
      if (targetUser == null) {
        return;
      }

      final updatedUser = UserModel(
        id: targetUser.id,
        username: targetUser.username,
        passwordHash: targetUser.passwordHash,
        profileImageUrl: targetUser.profileImageUrl,
        rating: averageRating,
        role: targetUser.role,
        bio: targetUser.bio,
        createdAt: targetUser.createdAt,
        updatedAt: DateTime.now(),
      );

      await _userRepository.update(updatedUser);
    } catch (e) {
      rethrow;
    }
  }

  // Basic CRUD operations with rating updates
  Future<ReviewModel?> createReview(ReviewModel review) async {
    try {
      // Check if user has already reviewed this target
      final existingReview = await getUserReviewForTarget(
        review.userId,
        review.targetUserId,
      );
      if (existingReview != null) {
        throw Exception('User has already reviewed this target');
      }

      final id = await _reviewRepository.insert(review);
      final createdReview = await _reviewRepository.getById(id);

      // Update target user's rating
      await updateUserRating(review.targetUserId);

      if (createdReview != null) {
        return createdReview;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<ReviewModel?> getReviewById(int id) async {
    try {
      final newReview = await _reviewRepository.getById(id);
      if (newReview != null) {
        return newReview;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<ReviewModel?> updateReview(ReviewModel review) async {
    try {
      await _reviewRepository.update(review);
      final updatedReview = await _reviewRepository.getById(review.id);

      // Update target user's rating
      await updateUserRating(review.targetUserId);

      if (updatedReview != null) {
        return updatedReview;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      final review = await _reviewRepository.getById(reviewId);
      await _reviewRepository.delete(reviewId);

      // Update target user's rating
      await updateUserRating(review!.targetUserId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReviewModel>> getAllReviews() async {
    try {
      return await _reviewRepository.getAll();
    } catch (e) {
      rethrow;
    }
  }
}
