import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/tables/tables.dart';

class PromoMediaRepository extends BaseRepository<PromoMediaModel> {
  @override
  String get tableName => Tables.promoMedias.tableName;

  @override
  PromoMediaModel fromMap(Map<String, dynamic> map) {
    return PromoMediaModel(
      id: map[Tables.promoMedias.cols.id] as int,
      postId: map[Tables.promoMedias.cols.postId] as int,
      url: map[Tables.promoMedias.cols.url] as String,
      mediaType: map[Tables.promoMedias.cols.mediaType] as String?,
      createdAt: DateTime.parse(map[Tables.promoMedias.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.promoMedias.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(PromoMediaModel model) {
    return {
      Tables.promoMedias.cols.id: model.id,
      Tables.promoMedias.cols.postId: model.postId,
      Tables.promoMedias.cols.url: model.url,
      Tables.promoMedias.cols.mediaType: model.mediaType,
      Tables.promoMedias.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.promoMedias.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
