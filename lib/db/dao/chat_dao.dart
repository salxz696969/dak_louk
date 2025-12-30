import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/chat_model.dart';

class ChatDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertChat(ChatModel chat) async {
    try {
      final db = await _appDatabase.database;
      final map = chat.toMap();
      map.remove('id');
      return await db.insert('chats', map);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChatModel>> getChatsByUserIdAndTargetUserId(
    int userId,
    int targetUserId,
  ) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'chat_rooms',
        where:
            '(user_id = ? AND target_user_id = ?) OR (user_id = ? AND target_user_id = ?)',
        whereArgs: [userId, targetUserId, targetUserId, userId],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final chatRoomId = result.first['id'] as int;
        return getChatByChatRoomId(chatRoomId);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChatModel>> getChatByChatRoomId(int chatRoomId) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'chats',
        where: 'chat_room_id = ?',
        whereArgs: [chatRoomId],
      );
      if (result.isNotEmpty) {
        final userDao = UserDao();
        final List<ChatModel> chats = [];
        for (var map in result) {
          final user = await userDao.getUserById(map['user_id'] as int);
          chats.add(ChatModel.fromMap(map, user));
        }
        return chats;
      }
      return [
        ChatModel(
          id: 0,
          userId: 0,
          text: '',
          chatRoomId: chatRoomId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateChat(ChatModel chat) async {
    try {
      final db = await _appDatabase.database;
      return await db.update(
        'chats',
        chat.toMap(),
        where: 'id = ?',
        whereArgs: [chat.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteChat(int id) async {
    try {
      final db = await _appDatabase.database;
      return await db.delete('chats', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }

  Future<ChatModel> getLatestChatByChatRoomId(int chatRoomId) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'chats',
        where: 'chat_room_id = ?',
        orderBy: 'created_at DESC',
        limit: 1,
        whereArgs: [chatRoomId],
      );
      if (result.isNotEmpty) {
        final userDao = UserDao();
        final map = result.first;
        final user = await userDao.getUserById(map['user_id'] as int);
        return ChatModel.fromMap(map, user);
      }
      throw Exception('Chat not found');
    } catch (e) {
      rethrow;
    }
  }
}
