import 'package:dak_louk/utils/db/tables/tables.dart';

class ChatsTable implements DbTable<ChatsCols> {
  const ChatsTable();
  @override
  String get tableName => 'chats';
  @override
  ChatsCols get cols => ChatsCols();
}

class ChatsCols extends BaseCols {
  const ChatsCols();
  static const String userIdCol = 'user_id';
  static const String textCol = 'text';
  static const String chatRoomIdCol = 'chat_room_id';

  String get userId => userIdCol;
  String get text => textCol;
  String get chatRoomId => chatRoomIdCol;
}
