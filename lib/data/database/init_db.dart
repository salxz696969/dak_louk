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

const profileImages = [
  'assets/profiles/rafat.png',
  'assets/profiles/raksa.png',
  'assets/profiles/sal.png',
  'assets/profiles/tong.png',
  'assets/profiles/vatana.png',
];

const productImages = [
  'assets/images/apartment.jpg',
  'assets/images/bike.jpg',
  'assets/images/broom.jpg',
  'assets/images/car.jpg',
  'assets/images/dog_food.jpg',
  'assets/images/dog_toy.jpg',
  'assets/images/home.avif',
  'assets/images/ipad.jpg',
  'assets/images/motobike.webp',
  'assets/images/pants.jpg',
  'assets/images/pen.png',
  'assets/images/phone.jpg',
  'assets/images/plane_toy.jpg',
  'assets/images/plane.jpg',
  'assets/images/room.jpg',
  'assets/images/shirt.jpg',
  'assets/images/teddy.jpg',
  'assets/images/vacuum.jpg',
]; 

const productVideos = [
  'assets/live_videos/sample1.mp4',
  'assets/live_videos/sample2.mp4',
];

// Category-specific product mappings
final categoryProductMap = {
  'vehicles': ['car.jpg', 'bike.jpg', 'motobike.webp'],
  'property': ['apartment.jpg', 'home.avif', 'room.jpg', 'plane.jpg'],
  'electronics': ['ipad.jpg', 'phone.jpg', 'vacuum.jpg'],
  'home': ['broom.jpg', 'vacuum.jpg'],
  'fashion': ['pants.jpg', 'shirt.jpg'],
  'kids': ['plane_toy.jpg', 'teddy.jpg', 'pen.png'],
  'pets': ['dog_food.jpg', 'dog_toy.jpg'],
  'others': ['pen.png'],
};

final categoryProductNames = {
  'vehicles': ['Toyota Camry 2020', 'Honda CBR 600', 'Mountain Bike Pro', 'Yamaha Exciter 155'],
  'property': ['2BR Apartment Downtown', '3BR Family House', 'Studio Room City Center', 'Private Jet Charter'],
  'electronics': ['iPad Pro 11"', 'iPhone 14 Pro', 'Robot Vacuum Cleaner', 'Wireless Earbuds'],
  'home': ['Cleaning Broom Set', 'Coffee Maker Deluxe', 'Smart Vacuum Robot'],
  'fashion': ['Denim Jeans', 'Cotton T-Shirt', 'Formal Pants', 'Casual Shirt'],
  'kids': ['Toy Airplane', 'Teddy Bear Large', 'Colorful Pen Set', 'Learning Tablet'],
  'pets': ['Premium Dog Food 10kg', 'Chew Toy for Dogs', 'Pet Grooming Kit'],
  'others': ['Office Pen Set', 'Stationery Bundle', 'Misc Items'],
};

final categories = [
  'vehicles',
  'property',
  'electronics',
  'home',
  'fashion',
  'kids',
  'pets',
  'others',
];

final firstNames = [
  'Alex', 'Jordan', 'Taylor', 'Morgan', 'Casey',
  'Riley', 'Cameron', 'Jamie', 'Skyler', 'Avery',
  'Quinn', 'Parker', 'Dakota', 'Reese', 'Emerson',
];

final lastNames = [
  'Smith', 'Johnson', 'Brown', 'Williams', 'Jones',
  'Miller', 'Davis', 'Garcia', 'Rodriguez', 'Martinez',
  'Lee', 'Walker', 'Hall', 'Allen', 'Young',
];

String randomName(Random rand, int userId) {
  final first = firstNames[rand.nextInt(firstNames.length)];
  final last = lastNames[rand.nextInt(lastNames.length)];
  return '$first $last';
}

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
];

final notes = [
  'Leave the package at front door.',
  'Ring the doorbell twice, please.',
  'Call before delivery.',
  'Gate code is 2458.',
  'Apartment 3B, buzzer #042.',
  'Please deliver after 5pm.',
  'N/A',
  'Please handle with care, fragile items.',
  'Deliveries to side entrance.',
  'Someone home after 4pm.',
];

final phoneNumbers = [
  '217-555-3748', '718-555-2339', '512-555-9810',
  '415-555-2256', '303-555-8920', '206-555-1123',
  '503-555-4098', '305-555-7210', '617-555-3344',
  '614-555-9099',
];

final bios = [
  'Passionate entrepreneur and coffee enthusiast. Been selling online for 5+ years!',
  'Quality products at fair prices. Customer satisfaction is my priority.',
  'Small business owner. Thanks for supporting local sellers! 🙏',
  'Trusted seller since 2019. Fast replies and reliable service.',
];

final productDescriptions = {
  'vehicles': 'Well-maintained and in excellent condition. All documents available.',
  'property': 'Prime location with great amenities. Viewing available by appointment.',
  'electronics': 'Brand new with warranty. Original packaging included.',
  'home': 'High quality and durable. Perfect for everyday use.',
  'fashion': 'Comfortable fit, premium material. Various sizes available.',
  'kids': 'Safe and fun for children. Educational and entertaining.',
  'pets': 'Vet recommended and pet-approved. High quality ingredients.',
  'others': 'Excellent quality and great value for money.',
};

final chatMessages = [
  "Hi! Is this still available?",
  "Can you send more photos?",
  "What's your best price?",
  "Can you deliver today?",
  "I'm interested in buying this!",
  "Do you accept payment on delivery?",
  "Is the warranty still valid?",
  "Can we meet up tomorrow?",
];

final liveChatMessages = [
  "How much for this? 💰",
  "Still available?",
  "Show it closer please 👀",
  "This looks great! 👍",
  "I want to buy!",
  "What's the price? 💵",
  "Can you show the back?",
  "Add to cart! 🛒",
];

final reviewMessages = [
  "Great seller! Item exactly as described.",
  "Fast delivery and good communication.",
  "Very professional and helpful.",
  "Product quality exceeded expectations!",
  "Smooth transaction, highly recommend.",
  "Good service, will buy again.",
  "Item arrived safely and on time.",
  "Honest seller, no issues at all.",
];

Future<void> insertMockData(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
  final now = DateTime.now().toIso8601String();
  final rand = Random();

  print('📊 Starting data seeding...');

  // 1️⃣ USERS (50 regular users only)
  print('👥 Creating users...');
  for (int i = 1; i <= 50; i++) {
    await db.insert(Tables.users.tableName, {
      Tables.users.cols.username: randomName(rand, i),
      Tables.users.cols.email: 'user$i@example.com',
      Tables.users.cols.passwordHash: Hasher.sha256Hash('password$i'),
      Tables.users.cols.phone: phoneNumbers[rand.nextInt(phoneNumbers.length)],
      Tables.users.cols.address: addresses[rand.nextInt(addresses.length)],
      Tables.users.cols.notes: notes[rand.nextInt(notes.length)],
      Tables.users.cols.profileImageUrl: profileImages[rand.nextInt(profileImages.length)],
      Tables.users.cols.bio: null, // Regular users don't need bios
      Tables.users.cols.createdAt: now,
      Tables.users.cols.updatedAt: now,
    });
  }

  // 2️⃣ MERCHANTS (20 merchants with unique profiles)
  print('🏪 Creating merchants...');
  for (int i = 1; i <= 20; i++) {
    await db.insert(Tables.merchants.tableName, {
      Tables.merchants.cols.userId: i, // First 20 users are merchants
      Tables.merchants.cols.username: randomName(rand, i),
      Tables.merchants.cols.email: 'merchant$i@example.com',
      Tables.merchants.cols.bio: bios[rand.nextInt(bios.length)],
      Tables.merchants.cols.passwordHash: Hasher.sha256Hash('merchant$i'),
      Tables.merchants.cols.rating: (rand.nextDouble() * 1.5) + 3.5, // 3.5-5.0
      Tables.merchants.cols.profileImage: profileImages[rand.nextInt(profileImages.length)],
      Tables.merchants.cols.createdAt: now,
      Tables.merchants.cols.updatedAt: now,
    });
  }

  // 3️⃣ PRODUCT_CATEGORIES
  print('📦 Creating categories...');
  for (int i = 0; i < categories.length; i++) {
    await db.insert(Tables.productCategories.tableName, {
      Tables.productCategories.cols.name: categories[i],
    });
  }

  // 4️⃣ PRODUCTS (5-15 products per merchant, category-specific)
  print('🛍️ Creating products...');
  int productId = 1;
  for (int merchantId = 1; merchantId <= 20; merchantId++) {
    final numProducts = rand.nextInt(11) + 5; // 5-15 products per merchant
    
    for (int j = 0; j < numProducts; j++) {
      final category = categories[rand.nextInt(categories.length)];
      final categoryIndex = categories.indexOf(category) + 1;
      final productNameList = categoryProductNames[category]!;
      
      await db.insert(Tables.products.tableName, {
        Tables.products.cols.merchantId: merchantId,
        Tables.products.cols.name: productNameList[rand.nextInt(productNameList.length)],
        Tables.products.cols.description: productDescriptions[category],
        Tables.products.cols.price: _getCategoryPrice(category, rand),
        Tables.products.cols.quantity: rand.nextInt(30) + 5, // 5-35 items
        Tables.products.cols.createdAt: now,
        Tables.products.cols.updatedAt: now,
      });

      // Assign appropriate category
      await db.insert(Tables.productCategoryMaps.tableName, {
        Tables.productCategoryMaps.cols.productId: productId,
        Tables.productCategoryMaps.cols.categoryId: categoryIndex,
      });

      // Add 2-4 relevant images per product
      final imageList = categoryProductMap[category]!;
      final numImages = rand.nextInt(3) + 2; // 2-4 images
      for (int k = 0; k < numImages; k++) {
        await db.insert(Tables.productMedias.tableName, {
          Tables.productMedias.cols.productId: productId,
          Tables.productMedias.cols.url: 'assets/images/${imageList[rand.nextInt(imageList.length)]}',
          Tables.productMedias.cols.mediaType: 'image',
          Tables.productMedias.cols.createdAt: now,
          Tables.productMedias.cols.updatedAt: now,
        });
      }

      productId++;
    }
  }

  final totalProducts = productId - 1;
  print('✅ Created $totalProducts products');

  // 5️⃣ POSTS (2-8 posts per merchant)
  print('📝 Creating posts...');
  int postId = 1;
  for (int merchantId = 1; merchantId <= 20; merchantId++) {
    final numPosts = rand.nextInt(7) + 2; // 2-8 posts
    
    for (int j = 0; j < numPosts; j++) {
      await db.insert(Tables.posts.tableName, {
        Tables.posts.cols.merchantId: merchantId,
        Tables.posts.cols.caption: postCaptions[rand.nextInt(postCaptions.length)],
        Tables.posts.cols.createdAt: now,
        Tables.posts.cols.updatedAt: now,
      });

      // Get merchant's products
      final merchantProducts = await db.query(
        Tables.products.tableName,
        where: '${Tables.products.cols.merchantId} = ?',
        whereArgs: [merchantId],
      );

      if (merchantProducts.isNotEmpty) {
        // Feature 1-3 products per post
        final numFeatured = rand.nextInt(3) + 1;
        final shuffled = List.from(merchantProducts)..shuffle(rand);
        
        for (int k = 0; k < numFeatured && k < shuffled.length; k++) {
          final productData = shuffled[k];
          await db.insert(Tables.postProducts.tableName, {
            Tables.postProducts.cols.postId: postId,
            Tables.postProducts.cols.productId: productData[Tables.products.cols.id],
          });
        }

        // Add 1-3 promo images
        final numPromoMedia = rand.nextInt(3) + 1;
        for (int k = 0; k < numPromoMedia; k++) {
          await db.insert(Tables.promoMedias.tableName, {
            Tables.promoMedias.cols.postId: postId,
            Tables.promoMedias.cols.url: productImages[rand.nextInt(productImages.length)],
            Tables.promoMedias.cols.mediaType: 'image',
            Tables.promoMedias.cols.createdAt: now,
            Tables.promoMedias.cols.updatedAt: now,
          });
        }
      }

      postId++;
    }
  }

  final totalPosts = postId - 1;
  print('✅ Created $totalPosts posts');

  // 6️⃣ POST_LIKES (realistic engagement)
  print('❤️ Creating post likes...');
  for (int pId = 1; pId <= totalPosts; pId++) {
    final numLikes = rand.nextInt(30); // 0-30 likes per post
    final likedBy = <int>{};
    
    for (int j = 0; j < numLikes; j++) {
      final userId = rand.nextInt(50) + 1;
      if (likedBy.add(userId)) {
        try {
          await db.insert(Tables.postLikes.tableName, {
            Tables.postLikes.cols.userId: userId,
            Tables.postLikes.cols.postId: pId,
            Tables.postLikes.cols.createdAt: now,
            Tables.postLikes.cols.updatedAt: now,
          });
        } catch (e) {
          // Skip duplicates
        }
      }
    }
  }

  // 7️⃣ POST_SAVES (less common than likes)
  print('🔖 Creating post saves...');
  for (int pId = 1; pId <= totalPosts; pId++) {
    final numSaves = rand.nextInt(10); // 0-10 saves per post
    final savedBy = <int>{};
    
    for (int j = 0; j < numSaves; j++) {
      final userId = rand.nextInt(50) + 1;
      if (savedBy.add(userId)) {
        try {
          await db.insert(Tables.postSaves.tableName, {
            Tables.postSaves.cols.userId: userId,
            Tables.postSaves.cols.postId: pId,
            Tables.postSaves.cols.createdAt: now,
            Tables.postSaves.cols.updatedAt: now,
          });
        } catch (e) {
          // Skip duplicates
        }
      }
    }
  }

  // 8️⃣ LIVE_STREAMS (1-3 per merchant)
  print('📹 Creating live streams...');
  for (int merchantId = 1; merchantId <= 20; merchantId++) {
    final numStreams = rand.nextInt(3) + 1;
    
    for (int j = 0; j < numStreams; j++) {
      final streamId = await db.insert(Tables.liveStreams.tableName, {
        Tables.liveStreams.cols.merchantId: merchantId,
        Tables.liveStreams.cols.title: 'Live Selling - ${randomName(rand, merchantId)}',
        Tables.liveStreams.cols.streamUrl: productVideos[rand.nextInt(productVideos.length)],
        Tables.liveStreams.cols.thumbnailUrl: productImages[rand.nextInt(productImages.length)],
        Tables.liveStreams.cols.viewCount: rand.nextInt(500) + 50,
        Tables.liveStreams.cols.createdAt: now,
        Tables.liveStreams.cols.updatedAt: now,
      });

      // Get merchant's products for stream
      final merchantProducts = await db.query(
        Tables.products.tableName,
        where: '${Tables.products.cols.merchantId} = ?',
        whereArgs: [merchantId],
      );

      if (merchantProducts.isNotEmpty) {
        final numStreamProducts = rand.nextInt(5) + 2; // 2-6 products
        final shuffled = List.from(merchantProducts)..shuffle(rand);
        
        for (int k = 0; k < numStreamProducts && k < shuffled.length; k++) {
          await db.insert(Tables.liveStreamProducts.tableName, {
            Tables.liveStreamProducts.cols.liveStreamId: streamId,
            Tables.liveStreamProducts.cols.productId: shuffled[k][Tables.products.cols.id],
          });
        }

        // Add 10-50 chat messages
        final numChats = rand.nextInt(41) + 10;
        for (int k = 0; k < numChats; k++) {
          final userId = rand.nextInt(50) + 1;
          await db.insert(Tables.liveStreamChats.tableName, {
            Tables.liveStreamChats.cols.liveStreamId: streamId,
            Tables.liveStreamChats.cols.userId: userId,
            Tables.liveStreamChats.cols.text: liveChatMessages[rand.nextInt(liveChatMessages.length)],
            Tables.liveStreamChats.cols.createdAt: now,
            Tables.liveStreamChats.cols.updatedAt: now,
          });
        }
      }
    }
  }

  // 9️⃣ CHAT_ROOMS (conversations between users and merchants)
  print('💬 Creating chat rooms...');
  final createdRooms = <String>{};
  for (int i = 1; i <= 60; i++) {
    final userId = rand.nextInt(50) + 1;
    final merchantId = rand.nextInt(20) + 1;
    final key = '$userId-$merchantId';
    
    if (createdRooms.add(key)) {
      final roomId = await db.insert(Tables.chatRooms.tableName, {
        Tables.chatRooms.cols.userId: userId,
        Tables.chatRooms.cols.merchantId: merchantId,
        Tables.chatRooms.cols.createdAt: now,
        Tables.chatRooms.cols.updatedAt: now,
      });

      // Add 3-15 messages per room
      final numMessages = rand.nextInt(13) + 3;
      for (int j = 0; j < numMessages; j++) {
        final isUserSender = rand.nextBool();
        await db.insert(Tables.chats.tableName, {
          Tables.chats.cols.chatRoomId: roomId,
          Tables.chats.cols.senderId: isUserSender ? userId : merchantId,
          Tables.chats.cols.text: chatMessages[rand.nextInt(chatMessages.length)],
          Tables.chats.cols.createdAt: now,
          Tables.chats.cols.updatedAt: now,
        });
      }
    }
  }

  // 🔟 ORDERS (realistic purchase history)
  print('🛒 Creating orders...');
  for (int i = 1; i <= 40; i++) {
    final userId = rand.nextInt(50) + 1;
    final merchantId = rand.nextInt(20) + 1;
    
    final statusWeights = ['completed', 'completed', 'completed', 'delivering', 'accepted', 'waiting', 'cancelled'];
    final status = statusWeights[rand.nextInt(statusWeights.length)];
    
    final orderId = await db.insert(Tables.orders.tableName, {
      Tables.orders.cols.userId: userId,
      Tables.orders.cols.merchantId: merchantId,
      Tables.orders.cols.status: status,
      Tables.orders.cols.createdAt: now,
      Tables.orders.cols.updatedAt: now,
    });

    // Add 1-4 products per order
    final merchantProducts = await db.query(
      Tables.products.tableName,
      where: '${Tables.products.cols.merchantId} = ?',
      whereArgs: [merchantId],
    );

    if (merchantProducts.isNotEmpty) {
      final numProducts = rand.nextInt(4) + 1;
      final shuffled = List.from(merchantProducts)..shuffle(rand);
      
      for (int j = 0; j < numProducts && j < shuffled.length; j++) {
        await db.insert(Tables.orderProducts.tableName, {
          Tables.orderProducts.cols.orderId: orderId,
          Tables.orderProducts.cols.productId: shuffled[j][Tables.products.cols.id],
          Tables.orderProducts.cols.quantity: rand.nextInt(3) + 1,
        });
      }
    }
  }

  // 1️⃣1️⃣ REVIEWS (only for completed orders)
  print('⭐ Creating reviews...');
  final completedOrders = await db.query(
    Tables.orders.tableName,
    where: '${Tables.orders.cols.status} = ?',
    whereArgs: ['completed'],
  );

  for (final order in completedOrders) {
    if (rand.nextDouble() < 0.7) { // 70% of completed orders get reviewed
      final userId = order[Tables.orders.cols.userId] as int;
      final merchantId = order[Tables.orders.cols.merchantId] as int;
      
      try {
        await db.insert(Tables.reviews.tableName, {
          Tables.reviews.cols.userId: userId,
          Tables.reviews.cols.merchantId: merchantId,
          Tables.reviews.cols.text: reviewMessages[rand.nextInt(reviewMessages.length)],
          Tables.reviews.cols.rating: (rand.nextDouble() * 1.5) + 3.5, // 3.5-5.0
          Tables.reviews.cols.createdAt: now,
          Tables.reviews.cols.updatedAt: now,
        });
      } catch (e) {
        // Skip if user already reviewed this merchant
      }
    }
  }

  // 1️⃣2️⃣ FOLLOWERS (users following merchants)
  print('👥 Creating follower relationships...');
  for (int userId = 1; userId <= 50; userId++) {
    final numFollowing = rand.nextInt(10); // Follow 0-10 merchants
    final following = <int>{};
    
    for (int j = 0; j < numFollowing; j++) {
      final merchantId = rand.nextInt(20) + 1;
      if (following.add(merchantId)) {
        try {
          await db.insert(Tables.followers.tableName, {
            Tables.followers.cols.followerId: userId,
            Tables.followers.cols.followedId: merchantId,
            Tables.followers.cols.createdAt: now,
            Tables.followers.cols.updatedAt: now,
          });
        } catch (e) {
          // Skip duplicates
        }
      }
    }
  }

  print('✅ Mock data seeding completed successfully!');
}

double _getCategoryPrice(String category, Random rand) {
  switch (category) {
    case 'vehicles':
      return (rand.nextDouble() * 20000) + 5000; // $5k-$25k
    case 'property':
      return (rand.nextDouble() * 500000) + 100000; // $100k-$600k
    case 'electronics':
      return (rand.nextDouble() * 800) + 200; // $200-$1000
    case 'home':
      return (rand.nextDouble() * 150) + 20; // $20-$170
    case 'fashion':
      return (rand.nextDouble() * 80) + 15; // $15-$95
    case 'kids':
      return (rand.nextDouble() * 60) + 10; // $10-$70
    case 'pets':
      return (rand.nextDouble() * 50) + 15; // $15-$65
    case 'others':
      return (rand.nextDouble() * 40) + 5; // $5-$45
    default:
      return (rand.nextDouble() * 100) + 10;
  }
}