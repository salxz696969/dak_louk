import 'dart:math';
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

  // 2️⃣ PRODUCT_CATEGORIES - Independent lookup table
  await db.execute('''
      CREATE TABLE product_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

  // 3️⃣ PRODUCTS - Depends on users (merchants)
  await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        merchant_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        quantity INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (merchant_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // 4️⃣ PRODUCT_CATEGORY_MAPS - Many-to-many between products and categories
  await db.execute('''
      CREATE TABLE product_category_maps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES product_categories(id) ON DELETE CASCADE,
        UNIQUE(product_id, category_id)
      )
    ''');

  // 5️⃣ PRODUCT_MEDIAS - Product images/videos
  await db.execute('''
      CREATE TABLE product_medias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        url TEXT NOT NULL,
        media_type TEXT CHECK(media_type IN ('image', 'video')),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

  // 6️⃣ POSTS - Merchant promotional posts
  await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        merchant_id INTEGER NOT NULL,
        caption TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (merchant_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // 7️⃣ POST_PRODUCTS - Many-to-many between posts and products
  await db.execute('''
      CREATE TABLE post_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
        UNIQUE(post_id, product_id)
      )
    ''');

  // 8️⃣ PROMO_MEDIAS - Post promotional media
  await db.execute('''
      CREATE TABLE promo_medias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        url TEXT NOT NULL,
        media_type TEXT CHECK(media_type IN ('image', 'video')),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      )
    ''');

  // 9️⃣ POST_LIKES - User likes on posts
  await db.execute('''
      CREATE TABLE post_likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        post_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
        UNIQUE(user_id, post_id)
      )
    ''');

  // 🔟 POST_SAVES - User saves on posts
  await db.execute('''
      CREATE TABLE post_saves (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        post_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
        UNIQUE(user_id, post_id)
      )
    ''');

  // 1️⃣1️⃣ LIVE_STREAMS - Merchant live streaming
  await db.execute('''
      CREATE TABLE live_streams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        merchant_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        stream_url TEXT NOT NULL,
        thumbnail_url TEXT,
        view_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (merchant_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // 1️⃣2️⃣ LIVE_STREAM_PRODUCTS - Products featured in live streams
  await db.execute('''
      CREATE TABLE live_stream_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        live_stream_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        FOREIGN KEY (live_stream_id) REFERENCES live_streams(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
        UNIQUE(live_stream_id, product_id)
      )
    ''');

  // 1️⃣3️⃣ LIVE_STREAM_CHATS - Chat messages in live streams
  await db.execute('''
      CREATE TABLE live_stream_chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        live_stream_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (live_stream_id) REFERENCES live_streams(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // 1️⃣4️⃣ CHAT_ROOMS - Private conversations between users and merchants
  await db.execute('''
      CREATE TABLE chat_rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        merchant_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (merchant_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, merchant_id)
      )
    ''');

  // 1️⃣5️⃣ CHATS - Messages in chat rooms
  await db.execute('''
      CREATE TABLE chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_room_id INTEGER NOT NULL,
        sender_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (chat_room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
        FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // 1️⃣6️⃣ CARTS - User shopping carts
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

  // 1️⃣7️⃣ ORDERS - Purchase orders
  await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        merchant_id INTEGER NOT NULL,
        status TEXT CHECK(status IN ('waiting', 'accepted', 'delivering', 'completed', 'cancelled')) DEFAULT 'waiting',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (merchant_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // 1️⃣8️⃣ ORDER_PRODUCTS - Products in orders with price snapshots
  await db.execute('''
      CREATE TABLE order_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER DEFAULT 1,
        price_snapshot REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

  // 1️⃣9️⃣ REVIEWS - User reviews for merchants
  await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        merchant_id INTEGER NOT NULL,
        text TEXT,
        rating REAL CHECK(rating >= 0.0 AND rating <= 5.0),
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (merchant_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, merchant_id)
      )
    ''');

  // 2️⃣0️⃣ FOLLOWERS - User following system
  await db.execute('''
      CREATE TABLE followers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        follower_id INTEGER NOT NULL,
        followed_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (followed_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(follower_id, followed_id)
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

const promoImages = [
  'assets/promo/coffee1.jpg',
  'assets/promo/coffee2.jpg',
  'assets/promo/coffee3.jpg',
  'assets/promo/coffee4.jpg',
];

const promoVideos = [
  'assets/live_videos/sample1.mp4',
  'assets/live_videos/sample2.mp4',
];

const categories = [
  'vehicles',
  'property',
  'electronics',
  'home',
  'fashion',
  'jobs',
  'services',
  'entertainment',
  'kids',
  'pets',
  'business',
  'others',
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

// Product names
final productNames = [
  "Premium Coffee Beans",
  "Wireless Bluetooth Headphones",
  "Organic Cotton T-Shirt",
  "Stainless Steel Water Bottle",
  "Smartphone Case",
  "Laptop Stand",
  "Yoga Mat",
  "Kitchen Knife Set",
  "LED Desk Lamp",
  "Backpack",
  "Running Shoes",
  "Skincare Set",
  "Board Game",
  "Plant Pot",
  "Candle Set",
];

// Post captions
final postCaptions = [
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

  // 1️⃣ USERS (50 merchants, 50 regular users)
  for (int i = 1; i <= 100; i++) {
    await db.insert('users', {
      'username': randomName(rand, i),
      'password_hash': 'hash_user$i',
      'profile_image_url': profileImage,
      'rating': (rand.nextDouble() * 2) + 3.0,
      'bio': bio[rand.nextInt(bio.length)],
      'role': i <= 50 ? 'merchant' : 'user', // First 50 are merchants
      'created_at': now,
      'updated_at': now,
    });
  }

  // 2️⃣ PRODUCT_CATEGORIES
  for (int i = 0; i < categories.length; i++) {
    await db.insert('product_categories', {'name': categories[i]});
  }

  // 3️⃣ PRODUCTS (created by merchants)
  for (int i = 1; i <= 200; i++) {
    final merchantId = rand.nextInt(50) + 1; // Random merchant (1-50)
    await db.insert('products', {
      'merchant_id': merchantId,
      'name': productNames[rand.nextInt(productNames.length)],
      'description':
          productDescriptions[rand.nextInt(productDescriptions.length)],
      'price': (rand.nextDouble() * 200) + 10, // $10-$210
      'quantity': rand.nextInt(50) + 1,
      'created_at': now,
      'updated_at': now,
    });
  }

  // 4️⃣ PRODUCT_CATEGORY_MAPS (assign categories to products)
  for (int productId = 1; productId <= 200; productId++) {
    // Each product gets 1-3 categories
    final numCategories = rand.nextInt(3) + 1;
    final assignedCategories = <int>{};

    for (int j = 0; j < numCategories; j++) {
      int categoryId;
      do {
        categoryId = rand.nextInt(categories.length) + 1;
      } while (assignedCategories.contains(categoryId));

      assignedCategories.add(categoryId);

      await db.insert('product_category_maps', {
        'product_id': productId,
        'category_id': categoryId,
      });
    }
  }

  // 5️⃣ PRODUCT_MEDIAS (images/videos for products)
  for (int productId = 1; productId <= 200; productId++) {
    // Each product gets 2-5 media files
    final numMedia = rand.nextInt(4) + 2;

    for (int j = 0; j < numMedia; j++) {
      final isVideo = rand.nextBool() && j == 0; // First media might be video

      await db.insert('product_medias', {
        'product_id': productId,
        'url': isVideo
            ? productVideos[rand.nextInt(productVideos.length)]
            : productImages[rand.nextInt(productImages.length)],
        'media_type': isVideo ? 'video' : 'image',
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // 6️⃣ POSTS (promotional posts by merchants)
  for (int i = 1; i <= 150; i++) {
    final merchantId = rand.nextInt(50) + 1; // Random merchant

    await db.insert('posts', {
      'merchant_id': merchantId,
      'caption': postCaptions[rand.nextInt(postCaptions.length)],
      'created_at': now,
      'updated_at': now,
    });
  }

  // 7️⃣ POST_PRODUCTS (products featured in posts)
  for (int postId = 1; postId <= 150; postId++) {
    // Each post features 1-4 products
    final numProducts = rand.nextInt(4) + 1;
    final featuredProducts = <int>{};

    for (int j = 0; j < numProducts; j++) {
      int productId;
      do {
        productId = rand.nextInt(200) + 1;
      } while (featuredProducts.contains(productId));

      featuredProducts.add(productId);

      await db.insert('post_products', {
        'post_id': postId,
        'product_id': productId,
      });
    }
  }

  // 8️⃣ PROMO_MEDIAS (promotional media for posts)
  for (int postId = 1; postId <= 150; postId++) {
    // Each post gets 1-3 promotional media
    final numMedia = rand.nextInt(3) + 1;

    for (int j = 0; j < numMedia; j++) {
      final isVideo = rand.nextBool() && j == 0;

      await db.insert('promo_medias', {
        'post_id': postId,
        'url': isVideo
            ? promoVideos[rand.nextInt(promoVideos.length)]
            : promoImages[rand.nextInt(promoImages.length)],
        'media_type': isVideo ? 'video' : 'image',
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // 9️⃣ POST_LIKES (users liking posts)
  for (int i = 1; i <= 500; i++) {
    final userId = rand.nextInt(50) + 51; // Regular users (51-100)
    final postId = rand.nextInt(150) + 1;

    // Try to insert, ignore if duplicate
    try {
      await db.insert('post_likes', {
        'user_id': userId,
        'post_id': postId,
        'created_at': now,
      });
    } catch (e) {
      // Ignore duplicate constraint errors
    }
  }

  // 🔟 POST_SAVES (users saving posts)
  for (int i = 1; i <= 200; i++) {
    final userId = rand.nextInt(50) + 51; // Regular users
    final postId = rand.nextInt(150) + 1;

    try {
      await db.insert('post_saves', {
        'user_id': userId,
        'post_id': postId,
        'created_at': now,
      });
    } catch (e) {
      // Ignore duplicates
    }
  }

  // 1️⃣1️⃣ LIVE_STREAMS (merchant live streams)
  for (int i = 1; i <= 50; i++) {
    final merchantId = rand.nextInt(50) + 1;

    await db.insert('live_streams', {
      'merchant_id': merchantId,
      'title': 'Live selling session ${i}',
      'stream_url': productVideos[rand.nextInt(productVideos.length)],
      'thumbnail_url': productImages[rand.nextInt(productImages.length)],
      'view_count': rand.nextInt(1000),
      'created_at': now,
      'updated_at': now,
    });
  }

  // 1️⃣2️⃣ LIVE_STREAM_PRODUCTS (products in live streams)
  for (int streamId = 1; streamId <= 50; streamId++) {
    final numProducts = rand.nextInt(5) + 1; // 1-5 products per stream
    final streamProducts = <int>{};

    for (int j = 0; j < numProducts; j++) {
      int productId;
      do {
        productId = rand.nextInt(200) + 1;
      } while (streamProducts.contains(productId));

      streamProducts.add(productId);

      await db.insert('live_stream_products', {
        'live_stream_id': streamId,
        'product_id': productId,
      });
    }
  }

  // 1️⃣3️⃣ LIVE_STREAM_CHATS (chat messages in streams)
  for (int streamId = 1; streamId <= 50; streamId++) {
    final numChats = rand.nextInt(50) + 10; // 10-60 chats per stream

    for (int j = 0; j < numChats; j++) {
      final userId = rand.nextInt(100) + 1; // Any user can chat

      await db.insert('live_stream_chats', {
        'live_stream_id': streamId,
        'user_id': userId,
        'text': liveChatMessages[rand.nextInt(liveChatMessages.length)],
        'created_at': now,
      });
    }
  }

  // 1️⃣4️⃣ CHAT_ROOMS (private conversations)
  for (int i = 1; i <= 100; i++) {
    final userId = rand.nextInt(50) + 51; // Regular user
    final merchantId = rand.nextInt(50) + 1; // Merchant

    try {
      await db.insert('chat_rooms', {
        'user_id': userId,
        'merchant_id': merchantId,
        'created_at': now,
        'updated_at': now,
      });
    } catch (e) {
      // Ignore duplicates
    }
  }

  // 1️⃣5️⃣ CHATS (messages in chat rooms)
  final chatRooms = await db.query('chat_rooms');
  for (final room in chatRooms) {
    final roomId = room['id'] as int;
    final userId = room['user_id'] as int;
    final merchantId = room['merchant_id'] as int;
    final numMessages = rand.nextInt(10) + 1;

    for (int j = 0; j < numMessages; j++) {
      final senderId = rand.nextBool() ? userId : merchantId;

      await db.insert('chats', {
        'chat_room_id': roomId,
        'sender_id': senderId,
        'text': chatMessages[rand.nextInt(chatMessages.length)],
        'created_at': now,
      });
    }
  }

  // 1️⃣6️⃣ CARTS (user shopping carts)
  for (int userId = 51; userId <= 100; userId++) {
    // Regular users only
    final numItems = rand.nextInt(5) + 1; // 1-5 items per cart
    final cartProducts = <int>{};

    for (int j = 0; j < numItems; j++) {
      int productId;
      do {
        productId = rand.nextInt(200) + 1;
      } while (cartProducts.contains(productId));

      cartProducts.add(productId);

      await db.insert('carts', {
        'user_id': userId,
        'product_id': productId,
        'quantity': rand.nextInt(3) + 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // 1️⃣7️⃣ ORDERS (purchase orders)
  for (int i = 1; i <= 80; i++) {
    final userId = rand.nextInt(50) + 51; // Regular user
    final merchantId = rand.nextInt(50) + 1; // Merchant
    final statuses = [
      'waiting',
      'accepted',
      'delivering',
      'completed',
      'cancelled',
    ];

    await db.insert('orders', {
      'user_id': userId,
      'merchant_id': merchantId,
      'status': statuses[rand.nextInt(statuses.length)],
      'created_at': now,
      'updated_at': now,
    });
  }

  // 1️⃣8️⃣ ORDER_PRODUCTS (products in orders)
  for (int orderId = 1; orderId <= 80; orderId++) {
    final numProducts = rand.nextInt(3) + 1; // 1-3 products per order

    for (int j = 0; j < numProducts; j++) {
      final productId = rand.nextInt(200) + 1;
      final priceSnapshot = (rand.nextDouble() * 200) + 10;

      await db.insert('order_products', {
        'order_id': orderId,
        'product_id': productId,
        'quantity': rand.nextInt(2) + 1,
        'price_snapshot': priceSnapshot,
      });
    }
  }

  // 1️⃣9️⃣ REVIEWS (user reviews for merchants)
  for (int i = 1; i <= 100; i++) {
    final userId = rand.nextInt(50) + 51; // Regular user
    final merchantId = rand.nextInt(50) + 1; // Merchant

    try {
      await db.insert('reviews', {
        'user_id': userId,
        'merchant_id': merchantId,
        'text': reviewMessages[rand.nextInt(reviewMessages.length)],
        'rating': (rand.nextDouble() * 2) + 3.0, // 3.0-5.0
        'created_at': now,
      });
    } catch (e) {
      // Ignore duplicates
    }
  }

  // 2️⃣0️⃣ FOLLOWERS (user following system)
  for (int i = 1; i <= 200; i++) {
    final followerId = rand.nextInt(100) + 1; // Any user
    final followedId = rand.nextInt(100) + 1; // Any user

    if (followerId != followedId) {
      // Can't follow yourself
      try {
        await db.insert('followers', {
          'follower_id': followerId,
          'followed_id': followedId,
          'created_at': now,
        });
      } catch (e) {
        // Ignore duplicates
      }
    }
  }
}
