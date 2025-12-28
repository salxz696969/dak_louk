import 'package:dak_louk/utils/db/tables/tables.dart';

class LiveStreamChatsTable implements DbTable<LiveStreamChatsCols> {
  const LiveStreamChatsTable();
  @override
  String get tableName => 'live_stream_chats';
  @override
  LiveStreamChatsCols get cols => LiveStreamChatsCols();
}

class LiveStreamChatsCols extends BaseCols {
  const LiveStreamChatsCols();

  static const String textCol = 'text';
  static const String userIdCol = 'user_id';
  static const String liveStreamIdCol = 'live_stream_id';

  String get text => textCol;
  String get userId => userIdCol;
  String get liveStreamId => liveStreamIdCol;
}
