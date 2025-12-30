import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/chat_dao.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/chat_room_model.dart';
import 'package:dak_louk/models/user_model.dart';

class ChatRoomDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertChatRoom(ChatRoomModel chatRoom) async {
    try {
      final db = await _appDatabase.database;
      final map = chatRoom.toMap();
      map.remove('id');
      return await db.insert('chat_rooms', map);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getChatRoomId(int userId, int targetUserId) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'chat_rooms',
        where:
            '(user_id = ? AND target_user_id = ?) OR (user_id = ? AND target_user_id = ?)',
        whereArgs: [userId, targetUserId, targetUserId, userId],
        limit: 1,
      );
      return result.isNotEmpty ? result.first['id'] as int : -1;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChatRoomModel>> getAllChatRoomsByUserId(int userId) async {
    try {
      final db = await _appDatabase.database;
      final result = await db.query(
        'chat_rooms',
        limit: 50,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      if (result.isNotEmpty) {
        final List<ChatRoomModel> chatRooms = [];
        final UserDao userDao = UserDao();
        final UserModel user = await userDao.getUserById(userId);
        final ChatDao chatDao = ChatDao();
        for (var map in result) {
          final targetUser = await userDao.getUserById(
            map['target_user_id'] as int,
          );
          final latestChat = await chatDao.getLatestChatByChatRoomId(
            map['id'] as int,
          );
          chatRooms.add(
            ChatRoomModel.fromMap(
              map,
              user,
              targetUser,
              latestChat.userId == userId,
              latestChat.text,
            ),
          );
        }
        return chatRooms;
      }
      throw Exception('ChatRoom not found');
    } catch (e) {
      rethrow;
    }
  }
}
