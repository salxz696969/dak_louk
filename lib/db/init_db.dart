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

// 🔹 Natural text pools
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

final productDescriptions = [
  "This is one of those items that just works. I've been selling it for a while now and the feedback has been really positive. It's well-made, durable, and does exactly what it's supposed to do. Perfect for everyday use and the price is very reasonable compared to similar products out there. If you're looking for something reliable without breaking the bank, this is a solid choice.",

  "I personally tested this before adding it to my shop and I'm impressed with the quality. The materials feel premium and it's built to last. Several of my regular customers have already bought this and they keep coming back for more. It's one of those products that sells itself once people try it. Great value for money and I stand behind it 100%.",

  "Honestly, I was surprised by how good this is for the price. It's been flying off the shelves lately and I can see why. The quality is consistent, it works exactly as described, and I haven't had a single complaint about it. Whether you're buying for yourself or as a gift, this is a safe bet. Plus, it ships quickly and arrives in perfect condition.",

  "This has become one of my bestsellers for good reason. The build quality is solid, it's easy to use right out of the box, and it just does what it promises. I've sold dozens of these and the customer satisfaction rate is nearly 100%. If you're on the fence about it, don't be - it's worth every cent and then some.",

  "I've been in this business long enough to know quality when I see it, and this product delivers. It's practical, well-designed, and priced fairly. My repeat customers always ask if I have this in stock because they trust it. The manufacturer really got it right with this one. Simple, effective, and reliable.",

  "Let me tell you, this item punches way above its weight class. For the price you're paying, you're getting something that could easily cost twice as much elsewhere. I use one myself and several of my family members have bought it after seeing mine. It's durable, functional, and honestly just a smart purchase if you need something dependable.",

  "This is what I call a no-brainer purchase. Good materials, solid construction, and it actually lasts. I've had customers message me months after buying to say it's still going strong. That's the kind of product I like to sell - something I can be proud of. If you need something that won't let you down, this is it.",

  "I stock this item specifically because my customers keep requesting it. It's become a staple in my shop and for good reason. The quality-to-price ratio is excellent, it's versatile enough for different uses, and it just works reliably every single time. Easy to recommend without hesitation.",
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
  "Really smooth transaction! The seller was super helpful and answered all my questions quickly. Would definitely buy from them again.",

  "Item arrived exactly as described in the post. No surprises, no issues. The seller communicated well throughout the process.",

  "Fast replies and very easy to deal with. The seller was professional and the whole process was hassle-free. Recommended!",

  "Had a great experience overall. The item is exactly what I needed and the seller made sure everything went smoothly. Happy customer here!",

  "Would absolutely buy from this seller again. Honest, responsive, and the product quality was spot on. Thanks!",

  "Seller was patient with all my questions and very accommodating. The item is great quality and arrived on time. Very satisfied!",

  "No complaints at all. Quick transaction, item as described, and good communication. What more could you ask for?",

  "Trustworthy seller with quality items. Everything went exactly as promised. Will definitely check their shop again.",
];

Future<void> insertMockData(Database db) async {
  final now = DateTime.now().toIso8601String();
  final rand = Random();

  // 1️⃣ USERS
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

  // 2️⃣ LIVE STREAMS
  for (int i = 1; i <= 50; i++) {
    await db.insert('live_stream', {
      'id': i,
      'url': productVideos[i % productVideos.length],
      'user_id': i,
      'title': 'Live selling now - join us!',
      'created_at': now,
      'updated_at': now,
    });
  }

  // 3️⃣ PRODUCTS
  for (int i = 1; i <= 50; i++) {
    await db.insert('products', {
      'id': i,
      'user_id': (i % 100) + 1,
      'title': postTitles[rand.nextInt(postTitles.length)],
      'description':
          productDescriptions[rand.nextInt(productDescriptions.length)],
      'category':
          ProductCategory.values[i % ProductCategory.values.length].name,
      'price': (rand.nextDouble() * 100).toStringAsFixed(2),
      'quantity': rand.nextInt(20) + 1,
      'live_stream_id': (i % 50) + 1,
      'created_at': now,
      'updated_at': now,
    });
  }

  // 4️⃣ POSTS
  for (int i = 1; i <= 50; i++) {
    await db.insert('posts', {
      'id': i,
      'user_id': (i % 100) + 1,
      'title': postTitles[rand.nextInt(postTitles.length)],
      'product_id': i,
      'category':
          ProductCategory.values[i % ProductCategory.values.length].name,
      'created_at': now,
      'updated_at': now,
    });
  }

  // 5️⃣ MEDIAS
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
  for (int lsId = 1; lsId <= 50; lsId++) {
    for (int j = 0; j < 2; j++) {
      await db.insert('live_stream_chats', {
        'id': liveChatId++,
        'text': liveChatMessages[rand.nextInt(liveChatMessages.length)],
        'user_id': lsId,
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
      'user_id': (i % 100) + 1,
      'product_id': i,
      'status': ProgressStatus.values[i % ProgressStatus.values.length].name,
      'created_at': now,
      'updated_at': now,
    });
  }
}
