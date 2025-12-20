import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/product_dao.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/post_model.dart';
import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/models/user_model.dart';

class PostDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertPost(Post post) async {
    final db = await _appDatabase.database;
    return await db.insert('posts', post.toMap());
  }

  Future<List<Post>> getAllPosts() async {
    final db = await _appDatabase.database;
    final result = await db.query('posts', limit: 20);

    final UserDao userDao = UserDao();
    final ProductDao productDao = ProductDao();

    final posts = await Future.wait(
      result.map((map) async {
        final User user = await userDao.getUserById(map['user_id'] as int);
        final Product product = await productDao.getProductById(
          map['product_id'] as int,
        );
        final postId = map['id'] as int;
        final mediaResults = await db.query(
          'medias',
          where: 'post_id = ?',
          whereArgs: [postId],
        );
        return Post.fromMap(
          map,
          product,
          user,
          mediaResults.map((media) => media['url'] as String).toList(),
        );
      }),
    );

    return posts;
  }

  Future<int> updatePost(Post post) async {
    final db = await _appDatabase.database;
    return await db.update(
      'posts',
      post.toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  Future<int> deletePost(int id) async {
    final db = await _appDatabase.database;
    return await db.delete('posts', where: 'id = ?', whereArgs: [id]);
  }
}
