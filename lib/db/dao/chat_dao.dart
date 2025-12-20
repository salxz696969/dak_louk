import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/chat_model.dart';

class ChatDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertChat(Chat chat) async {
    final db = await _appDatabase.database;
    return await db.insert('chats', chat.toMap());
  }

  Future<List<Chat>> getChatByChatRoomId(int chatRoomId) async {
    final db = await _appDatabase.database;
    final result = await db.query(
      'chats',
      where: 'chat_room_id = ?',
      limit: 20,
      whereArgs: [chatRoomId],
    );
    if (result.isNotEmpty) {
      final userDao = UserDao();
      final List<Chat> chats = [];
      for (var map in result) {
        final user = await userDao.getUserById(map['user_id'] as int);
        chats.add(Chat.fromMap(map, user));
      }
      return chats;
    }
    throw Exception('Chat not found');
  }

  Future<int> updateChat(Chat chat) async {
    final db = await _appDatabase.database;
    return await db.update(
      'chats',
      chat.toMap(),
      where: 'id = ?',
      whereArgs: [chat.id],
    );
  }

  Future<int> deleteChat(int id) async {
    final db = await _appDatabase.database;
    return await db.delete('chats', where: 'id = ?', whereArgs: [id]);
  }
}
