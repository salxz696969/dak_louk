import 'dart:math';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/core/utils/hash.dart';
import 'package:sqflite/sqflite.dart';

Future<void> initDb(Database db) async {
  // 1️⃣ USERS - Base table, no dependencies
  await db.execute('''
      CREATE TABLE ${Tables.users.tableName} (
        ${Tables.users.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.users.cols.username} TEXT NOT NULL,
        ${Tables.users.cols.email} TEXT UNIQUE NOT NULL,
        ${Tables.users.cols.passwordHash} TEXT NOT NULL,
        ${Tables.users.cols.profileImageUrl} TEXT,
        ${Tables.users.cols.phone} TEXT,
        ${Tables.users.cols.address} TEXT,
        ${Tables.users.cols.notes} TEXT,
        ${Tables.users.cols.bio} TEXT,
        ${Tables.users.cols.createdAt} TEXT NOT NULL,
        ${Tables.users.cols.updatedAt} TEXT NOT NULL
      )
    ''');

  // 2️⃣ MERCHANTS - Depends on users
  await db.execute('''
      CREATE TABLE ${Tables.merchants.tableName} (
        ${Tables.merchants.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.merchants.cols.userId} INTEGER NOT NULL,
        ${Tables.merchants.cols.rating} REAL DEFAULT 0.0,
        ${Tables.merchants.cols.username} TEXT NOT NULL,
        ${Tables.merchants.cols.email} TEXT,
        ${Tables.merchants.cols.bio} TEXT,
        ${Tables.merchants.cols.profileImage} TEXT,
        ${Tables.merchants.cols.passwordHash} TEXT,
        ${Tables.merchants.cols.createdAt} TEXT NOT NULL,
        ${Tables.merchants.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.merchants.cols.userId}) REFERENCES ${Tables.users.tableName}(${Tables.users.cols.id}) ON DELETE CASCADE
      )
    ''');

  // 3️⃣ PRODUCT_CATEGORIES - Independent lookup table
  await db.execute('''
      CREATE TABLE ${Tables.productCategories.tableName} (
        ${Tables.productCategories.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.productCategories.cols.name} TEXT UNIQUE NOT NULL
      )
    ''');

  // 4️⃣ PRODUCTS - Depends on merchants
  await db.execute('''
      CREATE TABLE ${Tables.products.tableName} (
        ${Tables.products.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.products.cols.merchantId} INTEGER NOT NULL,
        ${Tables.products.cols.name} TEXT NOT NULL,
        ${Tables.products.cols.description} TEXT,
        ${Tables.products.cols.price} REAL NOT NULL,
        ${Tables.products.cols.quantity} INTEGER DEFAULT 1,
        ${Tables.products.cols.createdAt} TEXT NOT NULL,
        ${Tables.products.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.products.cols.merchantId}) REFERENCES ${Tables.merchants.tableName}(${Tables.merchants.cols.id}) ON DELETE CASCADE
      )
    ''');

  // 5️⃣ PRODUCT_CATEGORY_MAPS - Many-to-many between products and categories
  await db.execute('''
      CREATE TABLE ${Tables.productCategoryMaps.tableName} (
        ${Tables.productCategoryMaps.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.productCategoryMaps.cols.productId} INTEGER NOT NULL,
        ${Tables.productCategoryMaps.cols.categoryId} INTEGER NOT NULL,
        FOREIGN KEY (${Tables.productCategoryMaps.cols.productId}) REFERENCES ${Tables.products.tableName}(${Tables.products.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.productCategoryMaps.cols.categoryId}) REFERENCES ${Tables.productCategories.tableName}(${Tables.productCategories.cols.id}) ON DELETE CASCADE,
        UNIQUE(${Tables.productCategoryMaps.cols.productId}, ${Tables.productCategoryMaps.cols.categoryId})
      )
    ''');

  // 6️⃣ PRODUCT_MEDIAS - Product images/videos
  await db.execute('''
      CREATE TABLE ${Tables.productMedias.tableName} (
        ${Tables.productMedias.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.productMedias.cols.productId} INTEGER NOT NULL,
        ${Tables.productMedias.cols.url} TEXT NOT NULL,
        ${Tables.productMedias.cols.mediaType} TEXT CHECK(${Tables.productMedias.cols.mediaType} IN ('image', 'video')),
        ${Tables.productMedias.cols.createdAt} TEXT NOT NULL,
        ${Tables.productMedias.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.productMedias.cols.productId}) REFERENCES ${Tables.products.tableName}(${Tables.products.cols.id}) ON DELETE CASCADE
      )
    ''');

  // 7️⃣ POSTS - Merchant promotional posts
  await db.execute('''
      CREATE TABLE ${Tables.posts.tableName} (
        ${Tables.posts.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.posts.cols.merchantId} INTEGER NOT NULL,
        ${Tables.posts.cols.caption} TEXT,
        ${Tables.posts.cols.createdAt} TEXT NOT NULL,
        ${Tables.posts.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.posts.cols.merchantId}) REFERENCES ${Tables.merchants.tableName}(${Tables.merchants.cols.id}) ON DELETE CASCADE
      )
    ''');

  // 8️⃣ POST_PRODUCTS - Many-to-many between posts and products
  await db.execute('''
      CREATE TABLE ${Tables.postProducts.tableName} (
        ${Tables.postProducts.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.postProducts.cols.postId} INTEGER NOT NULL,
        ${Tables.postProducts.cols.productId} INTEGER NOT NULL,
        FOREIGN KEY (${Tables.postProducts.cols.postId}) REFERENCES ${Tables.posts.tableName}(${Tables.posts.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.postProducts.cols.productId}) REFERENCES ${Tables.products.tableName}(${Tables.products.cols.id}) ON DELETE CASCADE,
        UNIQUE(${Tables.postProducts.cols.postId}, ${Tables.postProducts.cols.productId})
      )
    ''');

  // 9️⃣ PROMO_MEDIAS - Post promotional media
  await db.execute('''
      CREATE TABLE ${Tables.promoMedias.tableName} (
        ${Tables.promoMedias.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.promoMedias.cols.postId} INTEGER NOT NULL,
        ${Tables.promoMedias.cols.url} TEXT NOT NULL,
        ${Tables.promoMedias.cols.mediaType} TEXT CHECK(${Tables.promoMedias.cols.mediaType} IN ('image', 'video')),
        ${Tables.promoMedias.cols.createdAt} TEXT NOT NULL,
        ${Tables.promoMedias.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.promoMedias.cols.postId}) REFERENCES ${Tables.posts.tableName}(${Tables.posts.cols.id}) ON DELETE CASCADE
      )
    ''');

  // 🔟 POST_LIKES - User likes on posts
  await db.execute('''
      CREATE TABLE ${Tables.postLikes.tableName} (
        ${Tables.postLikes.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.postLikes.cols.userId} INTEGER NOT NULL,
        ${Tables.postLikes.cols.postId} INTEGER NOT NULL,
        ${Tables.postLikes.cols.createdAt} TEXT NOT NULL,
        ${Tables.postLikes.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.postLikes.cols.userId}) REFERENCES ${Tables.users.tableName}(${Tables.users.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.postLikes.cols.postId}) REFERENCES ${Tables.posts.tableName}(${Tables.posts.cols.id}) ON DELETE CASCADE,
        UNIQUE(${Tables.postLikes.cols.userId}, ${Tables.postLikes.cols.postId})
      )
    ''');

  // 1️⃣1️⃣ POST_SAVES - User saves on posts
  await db.execute('''
      CREATE TABLE ${Tables.postSaves.tableName} (
        ${Tables.postSaves.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.postSaves.cols.userId} INTEGER NOT NULL,
        ${Tables.postSaves.cols.postId} INTEGER NOT NULL,
        ${Tables.postSaves.cols.createdAt} TEXT NOT NULL,
        ${Tables.postSaves.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.postSaves.cols.userId}) REFERENCES ${Tables.users.tableName}(${Tables.users.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.postSaves.cols.postId}) REFERENCES ${Tables.posts.tableName}(${Tables.posts.cols.id}) ON DELETE CASCADE,
        UNIQUE(${Tables.postSaves.cols.userId}, ${Tables.postSaves.cols.postId})
      )
    ''');

  // 1️⃣2️⃣ LIVE_STREAMS - Merchant live streaming
  await db.execute('''
      CREATE TABLE ${Tables.liveStreams.tableName} (
        ${Tables.liveStreams.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.liveStreams.cols.merchantId} INTEGER NOT NULL,
        ${Tables.liveStreams.cols.title} TEXT NOT NULL,
        ${Tables.liveStreams.cols.streamUrl} TEXT NOT NULL,
        ${Tables.liveStreams.cols.thumbnailUrl} TEXT,
        ${Tables.liveStreams.cols.viewCount} INTEGER DEFAULT 0,
        ${Tables.liveStreams.cols.createdAt} TEXT NOT NULL,
        ${Tables.liveStreams.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.liveStreams.cols.merchantId}) REFERENCES ${Tables.merchants.tableName}(${Tables.merchants.cols.id}) ON DELETE CASCADE
      )
    ''');

  // 1️⃣3️⃣ LIVE_STREAM_PRODUCTS - Products featured in live streams
  await db.execute('''
      CREATE TABLE ${Tables.liveStreamProducts.tableName} (
        ${Tables.liveStreamProducts.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.liveStreamProducts.cols.liveStreamId} INTEGER NOT NULL,
        ${Tables.liveStreamProducts.cols.productId} INTEGER NOT NULL,
        FOREIGN KEY (${Tables.liveStreamProducts.cols.liveStreamId}) REFERENCES ${Tables.liveStreams.tableName}(${Tables.liveStreams.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.liveStreamProducts.cols.productId}) REFERENCES ${Tables.products.tableName}(${Tables.products.cols.id}) ON DELETE CASCADE,
        UNIQUE(${Tables.liveStreamProducts.cols.liveStreamId}, ${Tables.liveStreamProducts.cols.productId})
      )
    ''');

  // 1️⃣4️⃣ LIVE_STREAM_CHATS - Chat messages in live streams
  await db.execute('''
      CREATE TABLE ${Tables.liveStreamChats.tableName} (
        ${Tables.liveStreamChats.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.liveStreamChats.cols.liveStreamId} INTEGER NOT NULL,
        ${Tables.liveStreamChats.cols.userId} INTEGER NOT NULL,
        ${Tables.liveStreamChats.cols.text} TEXT NOT NULL,
        ${Tables.liveStreamChats.cols.createdAt} TEXT NOT NULL,
        ${Tables.liveStreamChats.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.liveStreamChats.cols.liveStreamId}) REFERENCES ${Tables.liveStreams.tableName}(${Tables.liveStreams.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.liveStreamChats.cols.userId}) REFERENCES ${Tables.users.tableName}(${Tables.users.cols.id}) ON DELETE CASCADE
      )
    ''');

  // 1️⃣5️⃣ CHAT_ROOMS - Private conversations between users and merchants
  await db.execute('''
      CREATE TABLE ${Tables.chatRooms.tableName} (
        ${Tables.chatRooms.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.chatRooms.cols.userId} INTEGER NOT NULL,
        ${Tables.chatRooms.cols.merchantId} INTEGER NOT NULL,
        ${Tables.chatRooms.cols.createdAt} TEXT NOT NULL,
        ${Tables.chatRooms.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.chatRooms.cols.userId}) REFERENCES ${Tables.users.tableName}(${Tables.users.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.chatRooms.cols.merchantId}) REFERENCES ${Tables.merchants.tableName}(${Tables.merchants.cols.id}) ON DELETE CASCADE,
        UNIQUE(${Tables.chatRooms.cols.userId}, ${Tables.chatRooms.cols.merchantId})
      )
    ''');

  // 1️⃣6️⃣ CHATS - Messages in chat rooms
  await db.execute('''
      CREATE TABLE ${Tables.chats.tableName} (
        ${Tables.chats.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.chats.cols.chatRoomId} INTEGER NOT NULL,
        ${Tables.chats.cols.senderId} INTEGER NOT NULL,
        ${Tables.chats.cols.text} TEXT NOT NULL,
        ${Tables.chats.cols.createdAt} TEXT NOT NULL,
        ${Tables.chats.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.chats.cols.chatRoomId}) REFERENCES ${Tables.chatRooms.tableName}(${Tables.chatRooms.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.chats.cols.senderId}) REFERENCES ${Tables.users.tableName}(${Tables.users.cols.id}) ON DELETE CASCADE
      )
    ''');

  // 1️⃣7️⃣ CARTS - User shopping carts
  await db.execute('''
      CREATE TABLE ${Tables.carts.tableName} (
        ${Tables.carts.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.carts.cols.userId} INTEGER NOT NULL,
        ${Tables.carts.cols.productId} INTEGER NOT NULL,
        ${Tables.carts.cols.quantity} INTEGER DEFAULT 1 CHECK(${Tables.carts.cols.quantity} > 0),
        ${Tables.carts.cols.createdAt} TEXT NOT NULL,
        ${Tables.carts.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.carts.cols.userId}) REFERENCES ${Tables.users.tableName}(${Tables.users.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.carts.cols.productId}) REFERENCES ${Tables.products.tableName}(${Tables.products.cols.id}) ON DELETE CASCADE,
        UNIQUE(${Tables.carts.cols.userId}, ${Tables.carts.cols.productId})
      )
    ''');

  // 1️⃣8️⃣ ORDERS - Purchase orders
  await db.execute('''
      CREATE TABLE ${Tables.orders.tableName} (
        ${Tables.orders.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.orders.cols.userId} INTEGER NOT NULL,
        ${Tables.orders.cols.merchantId} INTEGER NOT NULL,
        ${Tables.orders.cols.status} TEXT CHECK(${Tables.orders.cols.status} IN ('waiting', 'accepted', 'delivering', 'completed', 'cancelled')) DEFAULT 'waiting',
        ${Tables.orders.cols.createdAt} TEXT NOT NULL,
        ${Tables.orders.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.orders.cols.userId}) REFERENCES ${Tables.users.tableName}(${Tables.users.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.orders.cols.merchantId}) REFERENCES ${Tables.merchants.tableName}(${Tables.merchants.cols.id}) ON DELETE CASCADE
      )
    ''');

  // 1️⃣9️⃣ ORDER_PRODUCTS - Products in orders with price snapshots
  await db.execute('''
      CREATE TABLE ${Tables.orderProducts.tableName} (
        ${Tables.orderProducts.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.orderProducts.cols.orderId} INTEGER NOT NULL,
        ${Tables.orderProducts.cols.productId} INTEGER NOT NULL,
        ${Tables.orderProducts.cols.quantity} INTEGER DEFAULT 1,
        FOREIGN KEY (${Tables.orderProducts.cols.orderId}) REFERENCES ${Tables.orders.tableName}(${Tables.orders.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.orderProducts.cols.productId}) REFERENCES ${Tables.products.tableName}(${Tables.products.cols.id}) ON DELETE CASCADE
      )
    ''');

  // 2️⃣0️⃣ REVIEWS - User reviews for merchants
  await db.execute('''
      CREATE TABLE ${Tables.reviews.tableName} (
        ${Tables.reviews.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.reviews.cols.userId} INTEGER NOT NULL,
        ${Tables.reviews.cols.merchantId} INTEGER NOT NULL,
        ${Tables.reviews.cols.text} TEXT,
        ${Tables.reviews.cols.rating} REAL CHECK(${Tables.reviews.cols.rating} >= 0.0 AND ${Tables.reviews.cols.rating} <= 5.0),
        ${Tables.reviews.cols.createdAt} TEXT NOT NULL,
        ${Tables.reviews.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.reviews.cols.userId}) REFERENCES ${Tables.users.tableName}(${Tables.users.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.reviews.cols.merchantId}) REFERENCES ${Tables.merchants.tableName}(${Tables.merchants.cols.id}) ON DELETE CASCADE,
        UNIQUE(${Tables.reviews.cols.userId}, ${Tables.reviews.cols.merchantId})
      )
    ''');

  // 2️⃣1️⃣ FOLLOWERS - User following system
  await db.execute('''
      CREATE TABLE ${Tables.followers.tableName} (
        ${Tables.followers.cols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.followers.cols.followerId} INTEGER NOT NULL,
        ${Tables.followers.cols.followedId} INTEGER NOT NULL,
        ${Tables.followers.cols.createdAt} TEXT NOT NULL,
        ${Tables.followers.cols.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${Tables.followers.cols.followerId}) REFERENCES ${Tables.users.tableName}(${Tables.users.cols.id}) ON DELETE CASCADE,
        FOREIGN KEY (${Tables.followers.cols.followedId}) REFERENCES ${Tables.users.tableName}(${Tables.users.cols.id}) ON DELETE CASCADE,
        UNIQUE(${Tables.followers.cols.followerId}, ${Tables.followers.cols.followedId})
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
  'assets/images/coffee1.png',
  'assets/images/coffee2.png',
  'assets/images/coffee3.png',
  'assets/images/coffee4.png',
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

final addresses = [
  '123 Main St, Springfield, IL 62704, USA',
  '456 Elm Ave, Brooklyn, NY 11211, USA',
  '789 Oak Blvd, Austin, TX 78702, USA',
  '101 Pine Rd, San Francisco, CA 94107, USA',
  '234 Maple St, Denver, CO 80205, USA',
  '1781 Willow Ln, Seattle, WA 98103, USA',
  '652 Cedar Dr, Portland, OR 97214, USA',
  '350 Birch Pl, Miami, FL 33101, USA',
  '72 Cherry Ct, Boston, MA 02118, USA',
  '890 Aspen Cir, Columbus, OH 43215, USA',
  '230 Magnolia Ave, Nashville, TN 37206, USA',
  '400 Spruce Ter, Minneapolis, MN 55407, USA',
  '385 Hickory Way, Raleigh, NC 27605, USA',
  '2000 Sycamore St, Phoenix, AZ 85018, USA',
  '1013 Palm Dr, Los Angeles, CA 90026, USA',
  '9 Jasmine Blvd, Atlanta, GA 30308, USA',
  '876 Poplar Park, Kansas City, MO 64108, USA',
  '155 Redwood Ln, Salt Lake City, UT 84101, USA',
  '545 Alder Blvd, Madison, WI 53703, USA',
  '27 Dogwood Pl, Richmond, VA 23220, USA',
];

final notes = [
  'Leave the package at front door.',
  'Ring the doorbell twice, please.',
  'Call before delivery.',
  'Friendly golden retriever in the yard.',
  'Gate code is 2458.',
  'Apartment 3B, buzzer #042.',
  'Please deliver after 5pm.',
  'N/A',
  'Please handle with care, fragile items.',
  'Gate is usually open, come around back.',
  'Deliveries to side entrance.',
  'Someone home after 4pm.',
  'Park on the street, driveway is narrow.',
  'Package locker is in the lobby.',
  'Mail slot is on the right side of the house.',
  'No signature required.',
  'Knock loudly, bell not working.',
  'House is at the end of a long driveway.',
  'Please text me if running late.',
  'Use the service elevator for large items.',
];

final phoneNumbers = [
  '217-555-3748',
  '718-555-2339',
  '512-555-9810',
  '415-555-2256',
  '303-555-8920',
  '206-555-1123',
  '503-555-4098',
  '305-555-7210',
  '617-555-3344',
  '614-555-9099',
  '615-555-6031',
  '612-555-7878',
  '919-555-1442',
  '602-555-5550',
  '323-555-7654',
  '404-555-3322',
  '816-555-2288',
  '801-555-1017',
  '608-555-4126',
  '804-555-9890',
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
    await db.insert(Tables.users.tableName, {
      Tables.users.cols.username: randomName(rand, i),
      Tables.users.cols.email: 'user$i@gmail.com',
      Tables.users.cols.passwordHash: Hasher.sha256Hash('password$i'),
      Tables.users.cols.phone: phoneNumbers[rand.nextInt(phoneNumbers.length)],
      Tables.users.cols.address: addresses[rand.nextInt(addresses.length)],
      Tables.users.cols.notes: notes[rand.nextInt(notes.length)],
      Tables.users.cols.profileImageUrl: profileImage,
      Tables.users.cols.bio: bio[rand.nextInt(bio.length)],
      Tables.users.cols.createdAt: now,
      Tables.users.cols.updatedAt: now,
    });
  }

  // 2️⃣ MERCHANTS (50 merchants)
  for (int i = 1; i <= 50; i++) {
    await db.insert(Tables.merchants.tableName, {
      Tables.merchants.cols.userId: i,
      Tables.merchants.cols.username: randomName(rand, i),
      Tables.merchants.cols.email: 'merchant$i@gmail.com',
      Tables.merchants.cols.bio: bio[rand.nextInt(bio.length)],
      Tables.merchants.cols.passwordHash: Hasher.sha256Hash(
        'merchantpassword$i',
      ),
      Tables.merchants.cols.rating:
          (rand.nextDouble() * 2) + 3.0, // 3.0-5.0 rating
      Tables.merchants.cols.profileImage: profileImage,
      Tables.merchants.cols.createdAt: now,
      Tables.merchants.cols.updatedAt: now,
    });
  }
  // 2️⃣ PRODUCT_CATEGORIES
  for (int i = 0; i < categories.length; i++) {
    await db.insert(Tables.productCategories.tableName, {
      Tables.productCategories.cols.name: categories[i],
    });
  }

  // 3️⃣ PRODUCTS (created by merchants)
  for (int i = 1; i <= 200; i++) {
    final merchantId = rand.nextInt(50) + 1; // Random merchant (1-50)
    await db.insert(Tables.products.tableName, {
      Tables.products.cols.merchantId: merchantId,
      Tables.products.cols.name:
          productNames[rand.nextInt(productNames.length)],
      Tables.products.cols.description:
          productDescriptions[rand.nextInt(productDescriptions.length)],
      Tables.products.cols.price: (rand.nextDouble() * 200) + 10, // $10-$210
      Tables.products.cols.quantity: rand.nextInt(50) + 1,
      Tables.products.cols.createdAt: now,
      Tables.products.cols.updatedAt: now,
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

      await db.insert(Tables.productCategoryMaps.tableName, {
        Tables.productCategoryMaps.cols.productId: productId,
        Tables.productCategoryMaps.cols.categoryId: categoryId,
      });
    }
  }

  // 5️⃣ PRODUCT_MEDIAS (images only for products)
  for (int productId = 1; productId <= 200; productId++) {
    // Each product gets 2-5 media files (all images)
    final numMedia = rand.nextInt(4) + 2;

    for (int j = 0; j < numMedia; j++) {
      await db.insert(Tables.productMedias.tableName, {
        Tables.productMedias.cols.productId: productId,
        Tables.productMedias.cols.url:
            productImages[rand.nextInt(productImages.length)],
        Tables.productMedias.cols.mediaType: 'image',
        Tables.productMedias.cols.createdAt: now,
        Tables.productMedias.cols.updatedAt: now,
      });
    }
  }

  // 6️⃣ POSTS (promotional posts by merchants)
  for (int i = 1; i <= 150; i++) {
    final merchantId = rand.nextInt(50) + 1; // Random merchant

    await db.insert(Tables.posts.tableName, {
      Tables.posts.cols.merchantId: merchantId,
      Tables.posts.cols.caption:
          postCaptions[rand.nextInt(postCaptions.length)],
      Tables.posts.cols.createdAt: now,
      Tables.posts.cols.updatedAt: now,
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

      await db.insert(Tables.postProducts.tableName, {
        Tables.postProducts.cols.postId: postId,
        Tables.postProducts.cols.productId: productId,
      });
    }
  }

  // 8️⃣ PROMO_MEDIAS (images only for promotional media in posts)
  for (int postId = 1; postId <= 150; postId++) {
    // Each post gets 1-3 promotional media (all images)
    final numMedia = rand.nextInt(3) + 1;

    for (int j = 0; j < numMedia; j++) {
      await db.insert(Tables.promoMedias.tableName, {
        Tables.promoMedias.cols.postId: postId,
        Tables.promoMedias.cols.url:
            promoImages[rand.nextInt(promoImages.length)],
        Tables.promoMedias.cols.mediaType: 'image',
        Tables.promoMedias.cols.createdAt: now,
        Tables.promoMedias.cols.updatedAt: now,
      });
    }
  }

  // 9️⃣ POST_LIKES (users liking posts)
  for (int i = 1; i <= 500; i++) {
    final userId = rand.nextInt(50) + 51; // Regular users (51-100)
    final postId = rand.nextInt(150) + 1;

    // Try to insert, ignore if duplicate
    try {
      await db.insert(Tables.postLikes.tableName, {
        Tables.postLikes.cols.userId: userId,
        Tables.postLikes.cols.postId: postId,
        Tables.postLikes.cols.createdAt: now,
        Tables.postLikes.cols.updatedAt: now,
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
      await db.insert(Tables.postSaves.tableName, {
        Tables.postSaves.cols.userId: userId,
        Tables.postSaves.cols.postId: postId,
        Tables.postSaves.cols.createdAt: now,
        Tables.postSaves.cols.updatedAt: now,
      });
    } catch (e) {
      // Ignore duplicates
    }
  }

  // 1️⃣1️⃣ LIVE_STREAMS (merchant live streams -- retain videos here)
  for (int i = 1; i <= 50; i++) {
    final merchantId = rand.nextInt(50) + 1;

    await db.insert(Tables.liveStreams.tableName, {
      Tables.liveStreams.cols.merchantId: merchantId,
      Tables.liveStreams.cols.title: 'Live selling session ${i}',
      Tables.liveStreams.cols.streamUrl:
          productVideos[rand.nextInt(productVideos.length)],
      Tables.liveStreams.cols.thumbnailUrl:
          productImages[rand.nextInt(productImages.length)],
      Tables.liveStreams.cols.viewCount: rand.nextInt(1000),
      Tables.liveStreams.cols.createdAt: now,
      Tables.liveStreams.cols.updatedAt: now,
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

      await db.insert(Tables.liveStreamProducts.tableName, {
        Tables.liveStreamProducts.cols.liveStreamId: streamId,
        Tables.liveStreamProducts.cols.productId: productId,
      });
    }
  }

  // 1️⃣3️⃣ LIVE_STREAM_CHATS (chat messages in streams)
  for (int streamId = 1; streamId <= 50; streamId++) {
    final numChats = rand.nextInt(50) + 10; // 10-60 chats per stream

    for (int j = 0; j < numChats; j++) {
      final userId = rand.nextInt(100) + 1; // Any user can chat

      await db.insert(Tables.liveStreamChats.tableName, {
        Tables.liveStreamChats.cols.liveStreamId: streamId,
        Tables.liveStreamChats.cols.userId: userId,
        Tables.liveStreamChats.cols.text:
            liveChatMessages[rand.nextInt(liveChatMessages.length)],
        Tables.liveStreamChats.cols.createdAt: now,
        Tables.liveStreamChats.cols.updatedAt: now,
      });
    }
  }

  // 1️⃣4️⃣ CHAT_ROOMS (private conversations)
  for (int i = 1; i <= 100; i++) {
    final userId = rand.nextInt(50) + 51; // Regular user
    final merchantId = rand.nextInt(50) + 1; // Merchant

    try {
      await db.insert(Tables.chatRooms.tableName, {
        Tables.chatRooms.cols.userId: 1, // for easy testing
        Tables.chatRooms.cols.merchantId: merchantId,
        Tables.chatRooms.cols.createdAt: now,
        Tables.chatRooms.cols.updatedAt: now,
      });
    } catch (e) {
      // Ignore duplicates
    }
  }

  // 1️⃣5️⃣ CHATS (messages in chat rooms)
  final chatRooms = await db.query(Tables.chatRooms.tableName);
  for (final room in chatRooms) {
    final roomId = room[Tables.chatRooms.cols.id] as int;
    final userId = room[Tables.chatRooms.cols.userId] as int;
    final merchantId = room[Tables.chatRooms.cols.merchantId] as int;
    final numMessages = rand.nextInt(10) + 1;

    for (int j = 0; j < numMessages; j++) {
      final senderId = rand.nextBool() ? userId : merchantId;

      await db.insert(Tables.chats.tableName, {
        Tables.chats.cols.chatRoomId: roomId,
        Tables.chats.cols.senderId: senderId,
        Tables.chats.cols.text: chatMessages[rand.nextInt(chatMessages.length)],
        Tables.chats.cols.createdAt: now,
        Tables.chats.cols.updatedAt: now,
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

      await db.insert(Tables.carts.tableName, {
        Tables.carts.cols.userId: userId,
        Tables.carts.cols.productId: productId,
        Tables.carts.cols.quantity: rand.nextInt(3) + 1,
        Tables.carts.cols.createdAt: now,
        Tables.carts.cols.updatedAt: now,
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

    await db.insert(Tables.orders.tableName, {
      Tables.orders.cols.userId: userId,
      Tables.orders.cols.merchantId: merchantId,
      Tables.orders.cols.status: statuses[rand.nextInt(statuses.length)],
      Tables.orders.cols.createdAt: now,
      Tables.orders.cols.updatedAt: now,
    });
  }

  // 1️⃣8️⃣ ORDER_PRODUCTS (products in orders)
  for (int orderId = 1; orderId <= 80; orderId++) {
    final numProducts = rand.nextInt(3) + 1; // 1-3 products per order

    for (int j = 0; j < numProducts; j++) {
      final productId = rand.nextInt(200) + 1;

      await db.insert(Tables.orderProducts.tableName, {
        Tables.orderProducts.cols.orderId: orderId,
        Tables.orderProducts.cols.productId: productId,
        Tables.orderProducts.cols.quantity: rand.nextInt(2) + 1,
      });
    }
  }

  // 1️⃣9️⃣ REVIEWS (user reviews for merchants)
  for (int i = 1; i <= 100; i++) {
    final userId = rand.nextInt(50) + 51; // Regular user
    final merchantId = rand.nextInt(50) + 1; // Merchant

    try {
      await db.insert(Tables.reviews.tableName, {
        Tables.reviews.cols.userId: userId,
        Tables.reviews.cols.merchantId: merchantId,
        Tables.reviews.cols.text:
            reviewMessages[rand.nextInt(reviewMessages.length)],
        Tables.reviews.cols.rating: (rand.nextDouble() * 2) + 3.0, // 3.0-5.0
        Tables.reviews.cols.createdAt: now,
        Tables.reviews.cols.updatedAt: now,
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
        await db.insert(Tables.followers.tableName, {
          Tables.followers.cols.followerId: followerId,
          Tables.followers.cols.followedId: followedId,
          Tables.followers.cols.createdAt: now,
          Tables.followers.cols.updatedAt: now,
        });
      } catch (e) {
        // Ignore duplicates
      }
    }
  }
}
