import 'dart:math';
import 'package:dak_louk/domain/domain.dart';
import 'package:sqflite/sqflite.dart';

Future<void> initDb(Database db) async {
  // 1️⃣ USERS - Base table, no dependencies
  await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        profile_image_url TEXT,
        rating REAL DEFAULT 0.0,
        bio TEXT,
        role TEXT CHECK(role IN ('user', 'merchant')) DEFAULT 'user',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

  // 2️⃣ PRODUCTS - Depends on users only
  await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT CHECK(category IN ('vehicles','property','electronics','home','fashion','jobs','services','entertainment','kids','pets','business','others')),
        price REAL NOT NULL,
        quantity INTEGER DEFAULT 1,
        image_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // 3️⃣ LIVE_STREAMS - Depends on users only
  await db.execute('''
      CREATE TABLE live_streams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        thumbnail_url TEXT,
        view INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // 4️⃣ POSTS - Bridge table connecting products and live_streams
  await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        product_id INTEGER NOT NULL,
        live_stream_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
        FOREIGN KEY (live_stream_id) REFERENCES live_streams(id) ON DELETE SET NULL
      )
    ''');

  // 5️⃣ MEDIAS - Depends on posts
  await db.execute('''
      CREATE TABLE medias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT NOT NULL,
        post_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      )
    ''');

  // 6️⃣ CHAT_ROOMS - Depends on users
  await db.execute('''
      CREATE TABLE chat_rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        target_user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, target_user_id)
      )
    ''');

  // 7️⃣ CHATS - Depends on chat_rooms and users
  await db.execute('''
      CREATE TABLE chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        chat_room_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (chat_room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // 8️⃣ LIVE_STREAM_CHATS - Depends on live_streams and users
  await db.execute('''
      CREATE TABLE live_stream_chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        live_stream_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (live_stream_id) REFERENCES live_streams(id) ON DELETE CASCADE
      )
    ''');

  // 9️⃣ REVIEWS - Depends on users (both reviewer and target)
  await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        target_user_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        rating REAL NOT NULL CHECK(rating >= 0.0 AND rating <= 5.0),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, target_user_id)
      )
    ''');

  // 🔟 PRODUCT_PROGRESS - Depends on users and products
  await db.execute('''
      CREATE TABLE product_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        status TEXT CHECK(status IN ('waiting','accepted','delivering','completed','cancelled')) DEFAULT 'waiting',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

  // 1️⃣1️⃣ CARTS - Depends on users and products
  await db.execute('''
      CREATE TABLE carts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER DEFAULT 1 CHECK(quantity > 0),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
        UNIQUE(user_id, product_id)
      )
    ''');
}

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

String randomName(Random rand, int userId) {
  final first = firstNames[rand.nextInt(firstNames.length)];
  final last = lastNames[rand.nextInt(lastNames.length)];
  return '$first $last $userId'; // Add userId to ensure uniqueness
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
      'username': randomName(rand, i),
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

  // 4️⃣ POSTS - Bridge between products and live streams
  for (int i = 1; i <= 100; i++) {
    await db.insert('posts', {
      'id': 100 + i,
      'user_id': 1,
      'title': postTitles[rand.nextInt(postTitles.length)],
      'product_id': rand.nextInt(50) + 1, // 1-50 products available
      'live_stream_id': i <= 50
          ? rand.nextInt(20) + 1
          : null, // Only half have live streams
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

  // 6️⃣ CHAT ROOMS - Unique pairs of users
  for (int i = 1; i <= 10; i++) {
    final targetUserId = i + 1 <= 100
        ? i + 1
        : 1; // Wrap around to avoid out of bounds
    await db.insert('chat_rooms', {
      'id': i,
      'user_id': i,
      'target_user_id': targetUserId,
      'created_at': now,
      'updated_at': now,
    });
  }

  // 7️⃣ CHATS - Messages in chat rooms
  int chatId = 1;
  for (int roomId = 1; roomId <= 10; roomId++) {
    for (int j = 0; j < 5; j++) {
      await db.insert('chats', {
        'id': chatId++,
        'user_id': roomId, // Sender is the room creator
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

  // 9️⃣ REVIEWS - One review per user pair (unique constraint)
  int reviewId = 1;
  for (int target = 1; target <= 10; target++) {
    for (int reviewer = 11; reviewer <= 20; reviewer++) {
      // Different users to avoid self-review
      await db.insert('reviews', {
        'id': reviewId++,
        'user_id': reviewer,
        'target_user_id': target,
        'text': reviewMessages[rand.nextInt(reviewMessages.length)],
        'rating': (rand.nextDouble() * 2) + 3.0, // 3.0 to 5.0 rating
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

  // 1️⃣1️⃣ CARTS - Unique user-product pairs
  int cartId = 1;
  for (int userId = 1; userId <= 20; userId++) {
    // Create a set to track products already in cart for this user
    final productsInCart = <int>{};
    for (int j = 0; j < 3; j++) {
      int productId;
      do {
        productId = rand.nextInt(50) + 1;
      } while (productsInCart.contains(
        productId,
      )); // Ensure unique product per user

      productsInCart.add(productId);

      await db.insert('carts', {
        'id': cartId++,
        'user_id': userId,
        'product_id': productId,
        'quantity': rand.nextInt(3) + 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}
