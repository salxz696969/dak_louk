import 'dart:math';
import 'package:dak_louk/domain/domain.dart';
import 'package:sqflite/sqflite.dart';

Future<void> initDb(Database db) async {
  // users
  await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password_hash TEXT,
        profile_image_url TEXT,
        rating REAL,
        bio TEXT,
        role TEXT CHECK(role IN ('user', 'merchant')),
        created_at TEXT,
        updated_at TEXT
      )
    ''');

  // posts
  await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT,
        product_id INTEGER,
        live_stream_id INTEGER,
        category TEXT CHECK(category IN ('vehicles','property','electronics','home','fashion','jobs','services','entertainment','kids','pets','business','others')),
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        FOREIGN KEY (live_stream_id) REFERENCES live_streams(id) ON DELETE SET NULL
      )
    ''');

  // live_streams
  await db.execute('''
      CREATE TABLE live_streams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT,
        user_id INTEGER,
        title TEXT,
        thumbnail_url TEXT,
        view INTEGER,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // medias
  await db.execute('''
      CREATE TABLE medias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT,
        post_id INTEGER,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      )
    ''');

  // products
  await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT,
        description TEXT,
        category TEXT CHECK(category IN ('vehicles','property','electronics','home','fashion','jobs','services','entertainment','kids','pets','business','others')),
        price REAL,
        quantity INTEGER DEFAULT 1,
        image_url TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      )
    ''');

  // product_progress
  await db.execute('''
      CREATE TABLE product_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        product_id INTEGER,
        status TEXT CHECK(status IN ('waiting','accepted','delivering','completed','cancelled')),
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

  // chat_rooms
  await db.execute('''
      CREATE TABLE chat_rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        target_user_id INTEGER,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // chats
  await db.execute('''
      CREATE TABLE chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        chat_room_id INTEGER,
        text TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (chat_room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // live_stream_chats
  await db.execute('''
      CREATE TABLE live_stream_chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT,
        user_id INTEGER,
        live_stream_id INTEGER,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (live_stream_id) REFERENCES live_streams(id) ON DELETE CASCADE
      )
    ''');

  // reviews
  await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        target_user_id INTEGER,
        text TEXT,
        rating REAL,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // carts
  await db.execute('''
      CREATE TABLE carts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        product_id INTEGER,
        quantity INTEGER,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
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
  'Passionate entrepreneur, coffee enthusiast, and lifelong learner. With over a decade of experience in the local marketplace scene, I’ve built a reputation for delivering quality products and exceptional customer service. My journey began with a small online shop, and through dedication and hard work, I’ve grown into a trusted seller known for honesty, reliability, and a personal touch.',
  'As a merchant, I believe in the power of community and the importance of supporting local businesses. I take pride in curating a selection of products that not only meet but exceed customer expectations. Whether it’s sourcing unique items or providing everyday essentials, my goal is to create a shopping experience that feels personal and rewarding. When I’m not busy managing my store, you can find me exploring new coffee blends, hiking local trails, or volunteering in community initiatives.',
  'With a background in business management and a passion for e-commerce, I bring a strategic approach to my role as a merchant. I’m committed to continuous improvement, always seeking feedback from my customers to enhance their shopping experience. My store is more than just a business; it’s a reflection of my values and dedication to quality. I’m excited to connect with fellow entrepreneurs and customers alike, sharing my love for great products and exceptional service.',
];

final productDescriptions = [
  "This is one of those items that just works. I've been selling it for a while now and the feedback has been really positive.",
  "I personally tested this before adding it to my shop and I'm impressed with the quality.",
  "Honestly, I was surprised by how good this is for the price.",
  "This has become one of my bestsellers for good reason.",
  "I've been in this business long enough to know quality when I see it.",
  "Let me tell you, this item punches way above its weight class.",
  "This is what I call a no-brainer purchase.",
  "I stock this item specifically because my customers keep requesting it.",
];

final chatMessages = [
  "Hi there! Is this still available?",
  "Hey, how much are you asking for this?",
  "Can you deliver it today by any chance?",
  "I'm really interested in buying this!",
  "Do you still have this in stock?",
  "Thanks so much! Really appreciate it 😊",
  "Could you send me more pictures?",
  "Is the price negotiable at all?",
  "What time can you meet today?",
  "I'll take it! How do we proceed?",
  "Can you hold this for me until tomorrow?",
  "Does it come with a warranty?",
  "How long have you had this?",
  "Is there any damage I should know about?",
  "Perfect! I'll pick it up this evening",
];

final liveChatMessages = [
  "How much for this one? 💰",
  "Is this available right now?",
  "Can you show it closer please?",
  "This looks really good! 👍",
  "Do you still have stock?",
  "I want to buy! How? 😊",
  "What's the quality like?",
  "Can you demo it?",
  "Shipping available?",
  "I'm interested! 🔥",
  "What colors do you have?",
  "Price please?",
  "Still selling?",
  "Looks perfect for me!",
  "How do I order?",
];

final reviewMessages = [
  "Really smooth transaction! The seller was super helpful.",
  "Item arrived exactly as described in the post.",
  "Fast replies and very easy to deal with.",
  "Had a great experience overall.",
  "Would absolutely buy from this seller again.",
  "Seller was patient with all my questions.",
  "No complaints at all.",
  "Trustworthy seller with quality items.",
];

Future<void> insertMockData(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');

  final now = DateTime.now().toIso8601String();
  final rand = Random();

  // USERS
  for (int i = 1; i <= 100; i++) {
    await db.insert('users', {
      'id': i,
      'username': 'user$i',
      'password_hash': 'hash_user$i',
      'profile_image_url': profileImage,
      'rating': (rand.nextDouble() * 2) + 3.0,
      'bio': bio[rand.nextInt(bio.length)],
      'role': i % 2 == 0 ? 'merchant' : 'user',
      'created_at': now,
      'updated_at': now,
    });
  }

  // USER 1 POSTS (20)
  for (int i = 1; i <= 20; i++) {
    await db.insert('posts', {
      'id': 100 + i,
      'user_id': 1,
      'title': postTitles[rand.nextInt(postTitles.length)],
      'product_id': i,
      'category':
          ProductCategory.values[i % ProductCategory.values.length].name,
      'created_at': now,
      'updated_at': now,
    });
  }

  // MEDIAS FOR USER 1 POSTS
  for (int i = 1; i <= 20; i++) {
    for (int j = 0; j < 2; j++) {
      await db.insert('medias', {
        'url': productImages[rand.nextInt(productImages.length)],
        'post_id': 100 + i,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // USER 1 LIVE STREAMS (20 VIDEOS)
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

  // PRODUCTS
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
      'live_stream_id': i <= 20 ? i : null,
      'image_url': productImages[rand.nextInt(productImages.length)],
      'created_at': now,
      'updated_at': now,
    });
  }

  // POSTS (OTHER USERS)
  for (int i = 1; i <= 50; i++) {
    await db.insert('posts', {
      'id': i,
      'user_id': ((i * 2) % 100) + 2,
      'title': postTitles[rand.nextInt(postTitles.length)],
      'product_id': i,
      'category':
          ProductCategory.values[i % ProductCategory.values.length].name,
      'created_at': now,
      'updated_at': now,
    });
  }

  // MEDIAS
  for (int postId = 1; postId <= 50; postId++) {
    for (int j = 0; j < 2; j++) {
      await db.insert('medias', {
        'url': productImages[rand.nextInt(productImages.length)],
        'post_id': postId,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // PRODUCT PROGRESS
  int progressId = 1;
  for (int i = 1; i <= 50; i++) {
    await db.insert('product_progress', {
      'id': progressId++,
      'user_id': ((i * 2) % 100) + 2,
      'product_id': i,
      'status': ProgressStatus.values[i % ProgressStatus.values.length].name,
      'created_at': now,
      'updated_at': now,
    });
  }

  // CHAT ROOMS
  for (int i = 1; i <= 10; i++) {
    await db.insert('chat_rooms', {
      'id': i,
      'user_id': i,
      'target_user_id': i + 1,
      'created_at': now,
      'updated_at': now,
    });
  }

  // CHATS
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

  // LIVE STREAM CHATS
  int liveChatId = 1;
  for (int lsId = 1; lsId <= 20; lsId++) {
    for (int j = 0; j < 3; j++) {
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

  // REVIEWS
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

  // CARTS
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
