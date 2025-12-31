import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/tables/tables.dart';

class FollowerRepository extends BaseRepository<FollowerModel> {
  @override
  String get tableName => Tables.followers.tableName;

  @override
  FollowerModel fromMap(Map<String, dynamic> map) {
    return FollowerModel(
      id: map[Tables.followers.cols.id] as int,
      followerId: map[Tables.followers.cols.followerId] as int,
      followedId: map[Tables.followers.cols.followedId] as int,
      createdAt: DateTime.parse(map[Tables.followers.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.followers.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(FollowerModel model) {
    return {
      Tables.followers.cols.id: model.id,
      Tables.followers.cols.followerId: model.followerId,
      Tables.followers.cols.followedId: model.followedId,
      Tables.followers.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.followers.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
