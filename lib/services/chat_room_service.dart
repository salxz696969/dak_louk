import 'package:dak_louk/db/repositories/chat_room_repo.dart';
import 'package:dak_louk/models/chat_room_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class ChatRoomService {
  final ChatRoomRepository _chatRoomRepository = ChatRoomRepository();
  Future<List<ChatRoomModel>> getAllChatRoomsByUserId(int userId) async {
    try {
      final statement = Clauses.where.eq(Tables.chatRooms.cols.userId, userId);
      final result = await _chatRoomRepository.queryThisTable(
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
