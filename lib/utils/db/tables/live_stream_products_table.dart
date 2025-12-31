import 'package:dak_louk/utils/db/tables/tables.dart';

class LiveStreamProductsTable implements DbTable<LiveStreamProductsCols> {
  const LiveStreamProductsTable();
  @override
  String get tableName => 'live_stream_products';
  @override
  LiveStreamProductsCols get cols => LiveStreamProductsCols();
}

class LiveStreamProductsCols extends BaseCols {
  const LiveStreamProductsCols();
  static const String liveStreamIdCol = 'live_stream_id';
  static const String productIdCol = 'product_id';

  String get liveStreamId => liveStreamIdCol;
  String get productId => productIdCol;
}
