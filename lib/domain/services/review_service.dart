import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/review_repo.dart';
import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ReviewService {
  late final currentUserId;
  final ReviewRepository _reviewRepository = ReviewRepository();
  final UserRepository _userRepository = UserRepository();

  ReviewService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  // Business logic methods migrated from ReviewRepository
  Future<List<ReviewVM>> getReviewsByMerchantId(int merchantId) async {
    try {
      final merchant = await _userRepository.getById(merchantId);
      if (merchant == null) {
        throw AppError(
          type: ErrorType.NOT_FOUND,
          message: 'Merchant not found',
        );
      }
      if (merchant.id != merchantId) {
        throw AppError(type: ErrorType.FORBIDDEN, message: 'Forbidden');
      }
      final statement = Clauses.where.eq(
        Tables.reviews.cols.merchantId,
        merchantId,
      );
      final reviews = await _reviewRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.reviews.cols.createdAt).clause,
      );
      if (reviews.isNotEmpty) {
        return reviews.map((review) => ReviewVM.fromRaw(review)).toList();
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'Reviews not found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get reviews',
      );
    }
  }

  // Additional business logic methods
  Future<List<ReviewVM>> getReviewsByUserId(int userId) async {
    try {
      final statement = Clauses.where.eq(Tables.reviews.cols.userId, userId);
      final reviews = await _reviewRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: Clauses.orderBy.desc(Tables.reviews.cols.createdAt).clause,
      );
      if (reviews.isNotEmpty) {
        return reviews.map((review) => ReviewVM.fromRaw(review)).toList();
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'Reviews not found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get reviews',
      );
    }
  }

  Future<double> getAverageRatingForMerchant(int merchantId) async {
    try {
      final statement = Clauses.where.eq(
        Tables.reviews.cols.merchantId,
        merchantId,
      );
      final reviews = await _reviewRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );

      if (reviews.isEmpty) {
        return 0.0;
      }

      final totalRating = reviews.fold<num>(
        0.0,
        (sum, review) => sum + (review.rating ?? 0),
      );
      return totalRating / reviews.length;
    } catch (e) {
      rethrow;
    }
  }

  // Basic CRUD operations with rating updates
  Future<ReviewVM?> createReview(CreateReviewDTO dto) async {
    try {
      // Check if user has already reviewed this target
      final reviewModel = ReviewModel(
        id: 0,
        userId: currentUserId,
        merchantId: dto.merchantId,
        text: dto.text,
        rating: dto.rating,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await _reviewRepository.insert(reviewModel);
      if (id > 0) {
        final newReview = await _reviewRepository.getById(id);
        if (newReview != null) {
          return ReviewVM.fromRaw(newReview);
        }
        throw AppError(type: ErrorType.NOT_FOUND, message: 'Review not found');
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create review',
      );
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create review',
      );
    }
  }

  Future<ReviewVM?> updateReview(int id, UpdateReviewDTO dto) async {
    try {
      final review = await _reviewRepository.getById(id);
      if (review == null) {
        throw AppError(type: ErrorType.NOT_FOUND, message: 'Review not found');
      }
      if (review.userId != currentUserId) {
        throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
      }
      final reviewModel = ReviewModel(
        id: id,
        userId: currentUserId,
        merchantId: review.merchantId,
        text: dto.text ?? review.text,
        rating: dto.rating ?? review.rating,
        createdAt: review.createdAt,
        updatedAt: DateTime.now(),
      );
      await _reviewRepository.update(reviewModel);
      final newReview = await _reviewRepository.getById(id);
      if (newReview != null) {
        return ReviewVM.fromRaw(newReview);
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'Review not found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to update review',
      );
    }
  }
}
