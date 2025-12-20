import 'package:dak_louk/models/live_stream_chat_model.dart';
import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/models/user_model.dart';

class LiveStream {
  final int id;
  final String url;
  final int userId;
  final String title;

  final User? user;
  final List<Product>? products;
  final List<LiveStreamChat>? liveStreamChats;

  LiveStream({
    required this.id,
    required this.url,
    required this.userId,
    required this.title,
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
      user: user,
      products: products,
      liveStreamChats: liveStreamChats,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'url': url, 'user_id': userId, 'title': title};
  }
}
