import 'package:dak_louk/utils/db/tables/tables.dart';

class LiveStreamsTable implements DbTable<LiveStreamsCols> {
  const LiveStreamsTable();
  @override
  String get tableName => 'live_streams';
  @override
  LiveStreamsCols get cols => LiveStreamsCols();
}

class LiveStreamsCols extends BaseCols {
  const LiveStreamsCols();
  static const String merchantIdCol = 'merchant_id';
  static const String titleCol = 'title';
  static const String streamUrlCol = 'stream_url';
  static const String thumbnailUrlCol = 'thumbnail_url';
  static const String viewCountCol = 'view_count';

  String get merchantId => merchantIdCol;
  String get title => titleCol;
  String get streamUrl => streamUrlCol;
  String get thumbnailUrl => thumbnailUrlCol;
  String get viewCount => viewCountCol;
}
