import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/product_dao.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/post_model.dart';
import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/models/user_model.dart';

class PostDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertPost(PostModel post) async {
    try {
      final db = await _appDatabase.database;
      final map = post.toMap();
      map.remove('id');
      return await db.insert('posts', map);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> getAllPosts(String category, int limit) async {
    try {
      final db = await _appDatabase.database;
      List<Map<String, dynamic>> result = <Map<String, dynamic>>[];
      if (limit <= 0) {
        limit = 100;
      }
      if (category == 'all') {
        result = await db.query('posts', limit: limit);
      } else {
        result = await db.query(
          'posts',
          limit: limit,
          where: 'category = ?',
          whereArgs: [category],
        );
      }

      final UserDao userDao = UserDao();
      final ProductDao productDao = ProductDao();

      final posts = await Future.wait(
        result.map((map) async {
          final UserModel user = await userDao.getUserById(
            map['user_id'] as int,
          );
          final ProductModel product = await productDao.getProductById(
            map['product_id'] as int,
          );
          final postId = map['id'] as int;
          final mediaResults = await db.query(
            'medias',
            where: 'post_id = ?',
            whereArgs: [postId],
          );
          return PostModel.fromMap(
            map,
            product,
            user,
            mediaResults.map((media) => media['url'] as String).toList(),
          );
        }),
      );

      return posts;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> getPostsByLiveStreamId(
    int liveStreamId,
  ) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'posts',
        where: 'live_stream_id = ?',
        whereArgs: [liveStreamId],
      );

      final UserDao userDao = UserDao();
      final ProductDao productDao = ProductDao();

      final posts = await Future.wait(
        result.map((map) async {
          final UserModel user = await userDao.getUserById(
            map['user_id'] as int,
          );
          final ProductModel product = await productDao.getProductById(
            map['product_id'] as int,
          );
          final postId = map['id'] as int;
          final mediaResults = await db.query(
            'medias',
            where: 'post_id = ?',
            whereArgs: [postId],
          );
          return PostModel.fromMap(
            map,
            product,
            user,
            mediaResults.map((media) => media['url'] as String).toList(),
          );
        }),
      );

      return posts;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostModel>> getPostsByUserId(int userId, int limit) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'posts',
        where: 'user_id = ?',
        limit: limit > 0 ? limit : 20,
        whereArgs: [userId],
      );

      final UserDao userDao = UserDao();
      final ProductDao productDao = ProductDao();

      final posts = await Future.wait(
        result.map((map) async {
          final UserModel user = await userDao.getUserById(
            map['user_id'] as int,
          );
          final ProductModel product = await productDao.getProductById(
            map['product_id'] as int,
          );
          final postId = map['id'] as int;
          final mediaResults = await db.query(
            'medias',
            where: 'post_id = ?',
            whereArgs: [postId],
          );
          return PostModel.fromMap(
            map,
            product,
            user,
            mediaResults.map((media) => media['url'] as String).toList(),
          );
        }),
      );

      return posts;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updatePost(PostModel post) async {
    try {
      final db = await _appDatabase.database;
      return await db.update(
        'posts',
        post.toMap(),
        where: 'id = ?',
        whereArgs: [post.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deletePost(int id) async {
    try {
      final db = await _appDatabase.database;
      return await db.delete('posts', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }
}
