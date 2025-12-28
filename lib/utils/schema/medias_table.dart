import 'package:dak_louk/utils/schema/tables.dart';

class MediasTable implements DbTable<MediasCols> {
  const MediasTable();
  @override
  String get tableName => 'medias';
  @override
  MediasCols get cols => MediasCols();
}

class MediasCols extends BaseCols {
  const MediasCols();

  static const String postIdCol = 'post_id';
  static const String urlCol = 'url';

  String get postId => postIdCol;
  String get url => urlCol;
}
