import 'package:dak_louk/utils/db/app_database.dart';
import 'package:dak_louk/db/repository/user_dao.dart';
import 'package:dak_louk/models/chat_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class ChatDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertChat(ChatModel chat) async {
    try {
      final db = await _appDatabase.database;
      final map = chat.toMap();
      map.remove(Tables.id);
      return await db.insert('chats', map);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChatModel>> getChatByChatRoomId(int chatRoomId) async {
    try {
      final db = await _appDatabase.database;
      final statement = Clauses.where.eq(
        Tables.chats.cols.chatRoomId,
        chatRoomId,
      );
      final result = await db.query(
        Tables.chats.tableName,
        where: statement.clause,
        whereArgs: statement.args,
        limit: 20,
      );
      if (result.isNotEmpty) {
        final userDao = UserDao();
        final List<ChatModel> chats = [];
        for (var map in result) {
          final user = await userDao.getUserById(
            map[Tables.chats.cols.userId] as int,
          );
          chats.add(ChatModel.fromMap(map, user));
        }
        return chats;
      }
      throw Exception('Chat not found');
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateChat(ChatModel chat) async {
    try {
      final db = await _appDatabase.database;
      final statement = Clauses.where.eq(Tables.chats.cols.id, chat.id);
      return await db.update(
        Tables.chats.tableName,
        chat.toMap(),
        where: statement.clause,
        whereArgs: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteChat(int id) async {
    try {
      final db = await _appDatabase.database;
      final statement = Clauses.where.eq(Tables.chats.cols.id, id);
      return await db.delete(
        Tables.chats.tableName,
        where: statement.clause,
        whereArgs: statement.args,
      );
    } catch (e) {
      rethrow;
    }
  }
}
