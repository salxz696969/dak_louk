import 'package:dak_louk/db/repositories/chat_repo.dart';
import 'package:dak_louk/models/chat_model.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class ChatService {
  final ChatRepository _chatRepository = ChatRepository();

  Future<List<ChatModel>> getChatByChatRoomId(int chatRoomId) async {
    try {
      final statement = Clauses.where.eq(
        Tables.chats.cols.chatRoomId,
        chatRoomId,
      );
      final result = await _chatRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        limit: 20,
      );
      if (result.isNotEmpty) {
        return result;
      }
      throw Exception('Chat not found');
    } catch (e) {
      rethrow;
    }
  }
}
