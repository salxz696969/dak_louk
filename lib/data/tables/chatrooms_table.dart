import 'package:dak_louk/data/tables/tables.dart';

class ChatRoomsTable implements DbTable<ChatRoomsCols> {
  @override
  String get tableName => 'chat_rooms';
  @override
  ChatRoomsCols get cols => ChatRoomsCols();
  const ChatRoomsTable();
}

class ChatRoomsCols extends BaseCols {
  const ChatRoomsCols();
  static const String userIdCol = 'user_id';
  static const String merchantIdCol = 'merchant_id';

  String get userId => userIdCol;
  String get merchantId => merchantIdCol;
}
