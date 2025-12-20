import 'package:dak_louk/db/app_database.dart';
import 'package:dak_louk/db/dao/user_dao.dart';
import 'package:dak_louk/models/chat_room_model.dart';
import 'package:dak_louk/models/user_model.dart';

class ChatRoomDao {
  final AppDatabase _appDatabase = AppDatabase();

  Future<int> insertChatRoom(ChatRoom chatRoom) async {
    final db = await _appDatabase.database;
    return await db.insert('chat_rooms', chatRoom.toMap());
  }

  Future<List<ChatRoom>> getAllChatRoomsByUserId(int userId) async {
    final db = await _appDatabase.database;
    final result = await db.query(
      'chat_rooms',
      limit: 50,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      final List<ChatRoom> chatRooms = [];
      final UserDao userDao = UserDao();
      final User user = await userDao.getUserById(userId);
      for (var map in result) {
        final targetUser = await userDao.getUserById(
          map['target_user_id'] as int,
        );
        chatRooms.add(ChatRoom.fromMap(map, user, targetUser));
      }
      return chatRooms;
    }
    throw Exception('ChatRoom not found');
  }
}
