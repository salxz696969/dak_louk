import 'package:dak_louk/models/live_stream_chat_model.dart';
import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/models/user_model.dart';

class LiveStream {
  final int id;
  final String url;
  final int userId;
  final String title;
final DateTime createdAt;
  final DateTime updatedAt;

  final User? user;
  final List<Product>? products;
  final List<LiveStreamChat>? liveStreamChats;

  LiveStream({
    required this.id,
    required this.url,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.products,
    this.liveStreamChats,
  });

  factory LiveStream.fromMap(
    Map<String, dynamic> liveStream,
    User? user,
    List<Product>? products,
    List<LiveStreamChat>? liveStreamChats,
  ) {
    return LiveStream(
      id: liveStream['id'],
      url: liveStream['url'],
      userId: liveStream['user_id'],
      title: liveStream['title'],
      createdAt: DateTime.parse(liveStream['created_at']),
      updatedAt: DateTime.parse(liveStream['updated_at']),
      user: user,
      products: products,
      liveStreamChats: liveStreamChats,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'user_id': userId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
