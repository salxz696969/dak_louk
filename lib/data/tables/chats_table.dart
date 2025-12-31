import 'package:dak_louk/data/tables/tables.dart';

class ChatsTable implements DbTable<ChatsCols> {
  const ChatsTable();
  @override
  String get tableName => 'chats';
  @override
  ChatsCols get cols => ChatsCols();
}

// Note: Chats table only has created_at, not updated_at
class ChatsCols extends BaseColsCreatedOnly {
  const ChatsCols();
  static const String chatRoomIdCol = 'chat_room_id';
  static const String senderIdCol = 'sender_id';
  static const String textCol = 'text';

  String get chatRoomId => chatRoomIdCol;
  String get senderId => senderIdCol;
  String get text => textCol;
}
