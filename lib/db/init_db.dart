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

final firstNames = [
  'Alex',
  'Jordan',
  'Taylor',
  'Morgan',
  'Casey',
  'Riley',
  'Cameron',
  'Jamie',
  'Skyler',
  'Avery',
  'Quinn',
  'Parker',
  'Dakota',
  'Reese',
  'Emerson',
];

final lastNames = [
  'Smith',
  'Johnson',
  'Brown',
  'Williams',
  'Jones',
  'Miller',
  'Davis',
  'Garcia',
  'Rodriguez',
  'Martinez',
  'Lee',
  'Walker',
  'Hall',
  'Allen',
  'Young',
];

String randomName(Random rand) {
  final first = firstNames[rand.nextInt(firstNames.length)];
  final last = lastNames[rand.nextInt(lastNames.length)];
  return '$first $last';
}

// Your other mock data arrays
final postTitles = [
  "Fresh stock just arrived! ☕ Don't miss out",
  "Back in stock - grab yours while available",
  "Great quality at an amazing price 🔥",
  "Selling like crazy this week!",
  "My customers love this one ❤️",
  "You've got to check this out!",
  "Limited stock - first come first served",
  "Everyone's been asking for this",
  "Highly recommended by my regulars",
  "Simple, reliable, and worth every penny",
  "New arrival - better than expected!",
  "Perfect for daily use ✨",
  "Can't keep this one on the shelves",
  "Popular item - restock again!",
  "Honestly one of my favorites to sell",
];

final bio = [
  'Passionate entrepreneur, coffee enthusiast, and lifelong learner...',
  'As a merchant, I believe in the power of community...',
  'With a background in business management and a passion for e-commerce...',
];

final productDescriptions = [
  "This is one of those items that just works...",
  "I personally tested this before adding it to my shop...",
  "Honestly, I was surprised by how good this is for the price...",
  "This has become one of my bestsellers for good reason...",
];

final chatMessages = [
  "Hi there! Is this still available?",
  "Hey, how much are you asking for this?",
  "Can you deliver it today by any chance?",
  "I'm really interested in buying this!",
];

final liveChatMessages = [
  "How much for this one? 💰",
  "Is this available right now?",
  "Can you show it closer please?",
  "This looks really good! 👍",
];

final reviewMessages = [
  "Really smooth transaction! The seller was super helpful.",
  "Item arrived exactly as described in the post.",
  "Fast replies and very easy to deal with.",
  "Had a great experience overall.",
];

Future<void> insertMockData(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');

  final now = DateTime.now().toIso8601String();
  final rand = Random();

  // 1️⃣ USERS
  for (int i = 1; i <= 100; i++) {
    await db.insert('users', {
      'id': i,
      'username': randomName(rand),
      'password_hash': 'hash_user$i',
      'profile_image_url': profileImage,
      'rating': (rand.nextDouble() * 2) + 3.0,
      'bio': bio[rand.nextInt(bio.length)],
      'role': i % 2 == 0 ? 'merchant' : 'user',
      'created_at': now,
      'updated_at': now,
    });
  }

  // 2️⃣ PRODUCTS
  for (int i = 1; i <= 50; i++) {
    await db.insert('products', {
      'id': i,
      'user_id': 1,
      'title': postTitles[rand.nextInt(postTitles.length)],
      'description':
          productDescriptions[rand.nextInt(productDescriptions.length)],
      'category':
          ProductCategory.values[i % ProductCategory.values.length].name,
      'price': rand.nextDouble() * 100,
      'quantity': rand.nextInt(20) + 1,
      'image_url': productImages[rand.nextInt(productImages.length)],
      'created_at': now,
      'updated_at': now,
    });
  }

  // 3️⃣ LIVE STREAMS
  for (int i = 1; i <= 20; i++) {
    await db.insert('live_streams', {
      'id': i,
      'url': productVideos[i % productVideos.length],
      'user_id': 1,
      'title': 'Live selling now - join us!',
      'thumbnail_url': productImages[rand.nextInt(productImages.length)],
      'view': rand.nextInt(1000),
      'created_at': now,
      'updated_at': now,
    });
  }

  // 4️⃣ POSTS
  for (int i = 1; i <= 100; i++) {
    await db.insert('posts', {
      'id': 100 + i,
      'user_id': 1,
      'title': postTitles[rand.nextInt(postTitles.length)],
      'product_id': rand.nextInt(49) + 1,
      'live_stream_id': rand.nextInt(19) + 1,
      'category':
          ProductCategory.values[i % ProductCategory.values.length].name,
      'created_at': now,
      'updated_at': now,
    });
  }

  // 5️⃣ MEDIAS
  for (int postId = 101; postId <= 200; postId++) {
    for (int j = 0; j < 5; j++) {
      await db.insert('medias', {
        'url': productImages[rand.nextInt(productImages.length)],
        'post_id': postId,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // 6️⃣ CHAT ROOMS
  for (int i = 1; i <= 10; i++) {
    await db.insert('chat_rooms', {
      'id': i,
      'user_id': i,
      'target_user_id': i + 1,
      'created_at': now,
      'updated_at': now,
    });
  }

  // 7️⃣ CHATS
  int chatId = 1;
  for (int roomId = 1; roomId <= 10; roomId++) {
    for (int j = 0; j < 5; j++) {
      await db.insert('chats', {
        'id': chatId++,
        'user_id': roomId,
        'chat_room_id': roomId,
        'text': chatMessages[rand.nextInt(chatMessages.length)],
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // 8️⃣ LIVE STREAM CHATS
  int liveChatId = 1;
  for (int lsId = 1; lsId <= 20; lsId++) {
    for (int j = 0; j < 100; j++) {
      await db.insert('live_stream_chats', {
        'id': liveChatId++,
        'text': liveChatMessages[rand.nextInt(liveChatMessages.length)],
        'user_id': rand.nextInt(100) + 1,
        'live_stream_id': lsId,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // 9️⃣ REVIEWS
  int reviewId = 1;
  for (int target = 1; target <= 10; target++) {
    for (int reviewer = 1; reviewer <= 10; reviewer++) {
      if (reviewer == target) continue;
      await db.insert('reviews', {
        'id': reviewId++,
        'user_id': reviewer,
        'target_user_id': target,
        'text': reviewMessages[rand.nextInt(reviewMessages.length)],
        'rating': (rand.nextDouble() * 2) + 3.0,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // 🔟 PRODUCT PROGRESS
  int progressId = 1;
  for (int i = 1; i <= 50; i++) {
    await db.insert('product_progress', {
      'id': progressId++,
      'user_id': 1,
      'product_id': i,
      'status': ProgressStatus.values[i % ProgressStatus.values.length].name,
      'created_at': now,
      'updated_at': now,
    });
  }

  // 1️⃣1️⃣ CARTS
  int cartId = 1;
  for (int userId = 1; userId <= 20; userId++) {
    for (int j = 0; j < 3; j++) {
      await db.insert('carts', {
        'id': cartId++,
        'user_id': userId,
        'product_id': rand.nextInt(50) + 1,
        'quantity': rand.nextInt(3) + 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}
