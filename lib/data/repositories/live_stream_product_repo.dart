import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/tables/tables.dart';

class LiveStreamProductRepository
    extends BaseRepository<LiveStreamProductModel> {
  @override
  String get tableName => Tables.liveStreamProducts.tableName;

  @override
  LiveStreamProductModel fromMap(Map<String, dynamic> map) {
    return LiveStreamProductModel(
      id: map[Tables.liveStreamProducts.cols.id] as int,
      liveStreamId: map[Tables.liveStreamProducts.cols.liveStreamId] as int,
      productId: map[Tables.liveStreamProducts.cols.productId] as int,
    );
  }

  @override
  Map<String, dynamic> toMap(LiveStreamProductModel model) {
    return {
      Tables.liveStreamProducts.cols.id: model.id,
      Tables.liveStreamProducts.cols.liveStreamId: model.liveStreamId,
      Tables.liveStreamProducts.cols.productId: model.productId,
    };
  }
}
