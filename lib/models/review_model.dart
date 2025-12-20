import 'package:dak_louk/models/user_model.dart';

class Review {
  final int id;
  final int userId;
  final int targetUserId;
  final String text;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  final User? user;
  final User? targetUser;

  Review({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.text,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.targetUser,
  });

  factory Review.fromMap(Map<String, dynamic> review, User? user, User? targetUser) {
    return Review(
      id: review['id'],
      userId: review['user_id'],
      targetUserId: review['target_user_id'],
      text: review['text'],
      rating: review['rating'],
      createdAt: DateTime.parse(review['created_at']),
      updatedAt: DateTime.parse(review['updated_at']),
      user: user,
      targetUser: targetUser,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'target_user_id': targetUserId,
      'text': text,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
