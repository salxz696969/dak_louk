import 'package:dak_louk/db/repositories/repository_base.dart';
import 'package:dak_louk/models/chat_room_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class ChatRoomDao extends BaseRepository<ChatRoomModel> {
  @override
  String get tableName => Tables.chatRooms.tableName;

  @override
  ChatRoomModel fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      id: map[Tables.chatRooms.cols.id] as int,
      userId: map[Tables.chatRooms.cols.userId] as int,
      targetUserId: map[Tables.chatRooms.cols.targetUserId] as int,
      createdAt: DateTime.parse(map[Tables.chatRooms.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.chatRooms.cols.updatedAt] as String),
      user: null,
      targetUser: null,
    );
  }

  @override
  Map<String, dynamic> toMap(ChatRoomModel model) {
    return {
      Tables.chatRooms.cols.id: model.id,
      Tables.chatRooms.cols.userId: model.userId,
      Tables.chatRooms.cols.targetUserId: model.targetUserId,
      Tables.chatRooms.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.chatRooms.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }

  Future<List<ChatRoomModel>> getAllChatRoomsByUserId(int userId) async {
    try {
      final statement = Clauses.where.eq(Tables.chatRooms.cols.userId, userId);
      final result = await queryThisTable(
        where: statement.clause,
        args: statement.args,
        limit: 50,
      );
      if (result.isNotEmpty) {
        return result;
      }
      throw Exception('ChatRooms not found');
    } catch (e) {
      rethrow;
    }
  }
}
