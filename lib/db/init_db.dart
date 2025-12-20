import 'dart:math';
import 'package:dak_louk/models/product_category_enum.dart';
import 'package:dak_louk/models/progress_status_enum.dart';
import 'package:sqflite/sqflite.dart';

const profileImage = 'assets/profiles/profile1.png';
const productImages = [
  'assets/images/coffee1.png',
  'assets/images/coffee2.png',
  'assets/images/coffee3.png',
  'assets/images/coffee4.png',
  'assets/images/coffee5.png',
];
const productVideos = [
  'assets/live_videos/sample1.mp4',
  'assets/live_videos/sample2.mp4',
];

Future<void> insertMockData(Database db) async {
  final now = DateTime.now().toIso8601String();
  final rand = Random();

  // 1. USERS (must exist first for all FKs)
  for (int i = 1; i <= 100; i++) {
    await db.insert('users', {
      'id': i,
      'username': 'user$i',
      'password_hash': 'hash_user$i',
      'profile_image_url': profileImage,
      'rating': (rand.nextDouble() * 2) + 3.0,
      'role': i % 2 == 0 ? 'merchant' : 'user',
      'created_at': now,
      'updated_at': now,
    });
  }

  // 2. LIVE STREAMS (depends on users)
  for (int i = 1; i <= 20; i++) {
    await db.insert('live_stream', {
      'id': i,
      'url': productVideos[i % productVideos.length],
      'user_id': (i % 100) + 1,
      'title': 'Live Stream $i',
      'created_at': now,
      'updated_at': now,
    });
  }

  // 3. PRODUCTS (depends on users and live_streams)
  for (int i = 1; i <= 50; i++) {
    await db.insert('products', {
      'id': i,
      'user_id': (i % 100) + 1,
      'title': 'Product $i',
      'description': 'Description for product $i',
      'category':
          ProductCategory.values[i % ProductCategory.values.length].name,
      'price': (rand.nextDouble() * 100).toStringAsFixed(2),
      'quantity': rand.nextInt(20) + 1,
      'live_stream_id': (i % 20) + 1, // existing live_stream
      'created_at': now,
      'updated_at': now,
    });
  }

  // 4. POSTS (depends on users and products)
  for (int i = 1; i <= 50; i++) {
    await db.insert('posts', {
      'id': i,
      'user_id': (i % 100) + 1,
      'title': 'Post $i about Product $i',
      'product_id': i, // matches product ID
      'created_at': now,
      'updated_at': now,
    });
  }

  // 5. MEDIAS (depends on posts)
  for (int postId = 1; postId <= 50; postId++) {
    for (int j = 0; j < 2; j++) {
      await db.insert('medias', {
        'url': productImages[(postId + j) % productImages.length],
        'post_id': postId,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // 6. CHAT ROOMS (depends on users)
  for (int i = 1; i <= 10; i++) {
    await db.insert('chat_rooms', {
      'id': i,
      'user_id': i,
      'target_user_id': i + 1,
      'created_at': now,
      'updated_at': now,
    });
  }

  // 7. CHATS (depends on chat_rooms & users)
  int chatId = 1;
  for (int roomId = 1; roomId <= 10; roomId++) {
    for (int j = 0; j < 5; j++) {
      await db.insert('chats', {
        'id': chatId,
        'user_id': roomId, // pick one user in the room
        'chat_room_id': roomId,
        'text': 'Message $j in chat room $roomId',
        'created_at': now,
        'updated_at': now,
      });
      chatId++;
    }
  }

  // 8. LIVE STREAM CHATS (depends on live_stream & users)
  int liveChatId = 1;
  for (int lsId = 1; lsId <= 20; lsId++) {
    for (int j = 0; j < 2; j++) {
      await db.insert('live_stream_chats', {
        'id': liveChatId,
        'text': 'Message $j in live stream $lsId',
        'user_id': lsId, // user exists
        'live_stream_id': lsId, // live_stream exists
        'created_at': now,
        'updated_at': now,
      });
      liveChatId++;
    }
  }

  // 9. REVIEWS (everyone reviews first 10 users)
  int reviewId = 1;
  for (int target = 1; target <= 10; target++) {
    for (int reviewer = 1; reviewer <= 10; reviewer++) {
      if (reviewer == target) continue;
      await db.insert('reviews', {
        'id': reviewId++,
        'user_id': reviewer,
        'target_user_id': target,
        'text': 'Review from user $reviewer to user $target',
        'rating': (rand.nextDouble() * 2) + 3.0,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // 10. PRODUCT PROGRESS (depends on products & users)
  for (int i = 1; i <= 50; i++) {
    await db.insert('product_progress', {
      'id': i,
      'user_id': (i % 100) + 1,
      'product_id': i,
      'status': ProgressStatus.values[i % ProgressStatus.values.length].name,
      'created_at': now,
      'updated_at': now,
    });
  }
}
