import 'package:dak_louk/models/user_model.dart';

class ReviewModel {
  final int id;
  final int userId;
  final int targetUserId;
  final String text;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  final UserModel? user;
  final UserModel? targetUser;

  ReviewModel({
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
}
