import 'package:dak_louk/data/tables/tables.dart';

class LiveStreamChatsTable implements DbTable<LiveStreamChatsCols> {
  const LiveStreamChatsTable();
  @override
  String get tableName => 'live_stream_chats';
  @override
  LiveStreamChatsCols get cols => LiveStreamChatsCols();
}

// Note: Live stream chats table only has created_at, not updated_at
class LiveStreamChatsCols extends BaseCols {
  const LiveStreamChatsCols();
  static const String liveStreamIdCol = 'live_stream_id';
  static const String userIdCol = 'user_id';
  static const String textCol = 'text';

  String get liveStreamId => liveStreamIdCol;
  String get userId => userIdCol;
  String get text => textCol;
}
