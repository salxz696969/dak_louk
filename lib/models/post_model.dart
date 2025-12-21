import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/models/user_model.dart';
import 'package:flutter/material.dart';

class Post {
  final int id;
  final int userId;
  final String title;
  final int productId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final List<String>? images;
  final Product? product;
  final User? user;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
    this.images,
    this.product,
    this.user,
  });

  factory Post.fromMap(
    Map<String, dynamic> post,
    Product? product,
    User? user,
    List<String>? images,
  ) {
    return Post(
      id: post['id'],
      userId: post['user_id'],
      title: post['title'],
      productId: post['product_id'],
      createdAt: DateTime.parse(post['created_at']),
      updatedAt: DateTime.parse(post['updated_at']),
      product: product,
      user: user,
      images: images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'product_id': productId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  Map<String, dynamic> ui() {
    final user = this.user;
    final product = this.product;
    final images = (this.images?.map((img) => AssetImage(img)).toList()) ?? [];

    final profileImage = (user?.profileImageUrl != null)
        ? AssetImage(user!.profileImageUrl)
        : const AssetImage('assets/profiles/profile1.png');

    final username = user?.username ?? 'Unknown';
    final rating = user?.rating.toStringAsFixed(2) ?? '0.00';

    final quantity = product?.quantity.toString() ?? '1';
    final price = product?.price.toStringAsFixed(2) ?? '0.0';
    final description = product?.description ?? '';
    final title = this.title;
    final category = this.product?.category.name;

    final date = timeAgo(createdAt);

    return {
      'profileImage': profileImage,
      'username': username,
      'rating': rating,
      'quantity': quantity,
      'price': price,
      'description': description,
      'title': title,
      'category': category,
      'date': date,
      'images': images,
    };
  }
}
