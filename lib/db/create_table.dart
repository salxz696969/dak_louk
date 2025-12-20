// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';

Future<void> createTables(Database db) async {
  // users
  await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password_hash TEXT,
        profile_image_url TEXT,
        rating REAL,
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
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

  // live_stream
  await db.execute('''
      CREATE TABLE live_stream (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT,
        user_id INTEGER,
        title TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
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
        live_stream_id INTEGER,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (live_stream_id) REFERENCES live_stream(id) ON DELETE SET NULL
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
        FOREIGN KEY (live_stream_id) REFERENCES live_stream(id) ON DELETE CASCADE
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
}
