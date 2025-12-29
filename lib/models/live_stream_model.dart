import 'package:dak_louk/models/live_stream_chat_model.dart';
import 'package:dak_louk/models/post_model.dart';
import 'package:dak_louk/models/user_model.dart';
import 'package:flutter/widgets.dart';

class LiveStreamModel {
  final int id;
  final String url;
  final int userId;
  final String title;
  final String thumbnailUrl;
  final int view;
  final DateTime createdAt;
  final DateTime updatedAt;

  final UserModel? user;
  final List<PostModel>? posts;
  final List<LiveStreamChatModel>? liveStreamChats;

  LiveStreamModel({
    required this.id,
    required this.url,
    required this.userId,
    required this.title,
    required this.thumbnailUrl,
    required this.view,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.posts,
    this.liveStreamChats,
  });

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

  factory LiveStreamModel.fromMap(
    Map<String, dynamic> liveStream,
    UserModel? user,
    List<PostModel>? posts,
    List<LiveStreamChatModel>? liveStreamChats,
  ) {
    return LiveStreamModel(
      id: liveStream['id'],
      url: liveStream['url'],
      userId: liveStream['user_id'],
      title: liveStream['title'],
      thumbnailUrl: liveStream['thumbnail_url'],
      view: liveStream['view'],
      createdAt: DateTime.parse(liveStream['created_at']),
      updatedAt: DateTime.parse(liveStream['updated_at']),
      user: user,
      posts: posts,
      liveStreamChats: liveStreamChats,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'user_id': userId,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'view': view,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LiveStreamUI ui() {
    final user = this.user;
    final posts = this.posts ?? [];
    final liveStreamChats = this.liveStreamChats;

    // Use AssetImage for local assets, fallback if needed
    final thumbnail = (thumbnailUrl.isNotEmpty)
        ? AssetImage(thumbnailUrl)
        : const AssetImage('assets/thumbnails/default.png');

    final profileImage =
        (user?.profileImageUrl != null && user!.profileImageUrl.isNotEmpty)
        ? AssetImage(user.profileImageUrl)
        : const AssetImage('assets/profiles/profile1.png');

    final username = user?.username ?? 'Unknown';
    final rating = user?.rating.toStringAsFixed(2) ?? '0.00';

    // Use first post if available
    final post = posts.isNotEmpty ? posts.first : null;
    final quantity = post?.product?.quantity.toString() ?? '1';
    final price = post?.product?.price.toStringAsFixed(2) ?? '0.0';
    final description = post?.product?.description ?? '';
    final title = this.title;
    final category = post?.product?.category.name;
    final postId = post?.id ?? 0;
    final date = LiveStreamModel.timeAgo(createdAt);

    return LiveStreamUI(
      thumbnail: thumbnail,
      url: url,
      title: title,
      user: user!,
      posts: posts,
      liveStreamChats: liveStreamChats ?? [],
      timeAgo: date,
      profileImage: profileImage,
      username: username,
      rating: rating,
      view: view.toString(),
      quantity: quantity,
      price: price,
      description: description,
      category: category,
      postId: postId,
    );
  }
}

class LiveStreamUI {
  final AssetImage thumbnail;
  final String url;
  final String title;
  final UserModel user;
  final List<PostModel> posts;
  final List<LiveStreamChatModel> liveStreamChats;
  final String timeAgo;
  final String view;

  // Additional fields for UI, similar to PostUI
  final AssetImage profileImage;
  final String username;
  final String rating;
  final String quantity;
  final String price;
  final String description;
  final String? category;
  final int postId;

  LiveStreamUI({
    required this.thumbnail,
    required this.url,
    required this.title,
    required this.user,
    required this.posts,
    required this.liveStreamChats,
    required this.timeAgo,
    required this.profileImage,
    required this.view,
    required this.username,
    required this.rating,
    required this.quantity,
    required this.price,
    required this.description,
    required this.category,
    required this.postId,
  });
}
