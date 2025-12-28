import 'package:dak_louk/utils/schema/tables.dart';

class LiveStreamsTable implements DbTable<LiveStreamsCols> {
  const LiveStreamsTable();
  @override
  String get tableName => 'live_streams';
  @override
  LiveStreamsCols get cols => LiveStreamsCols();
}

class LiveStreamsCols extends BaseCols {
  const LiveStreamsCols();
  static const String urlCol = 'url';
  static const String userIdCol = 'user_id';
  static const String titleCol = 'title';
  static const String thumbnailUrlCol = 'thumbnail_url';
  static const String viewsCol = 'views';

  String get url => urlCol;
  String get userId => userIdCol;
  String get title => titleCol;
  String get thumbnailUrl => thumbnailUrlCol;
  String get views => viewsCol;
}
