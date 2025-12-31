import 'package:dak_louk/utils/db/tables/tables.dart';

class FollowersTable implements DbTable<FollowersCols> {
  const FollowersTable();
  @override
  String get tableName => 'followers';
  @override
  FollowersCols get cols => FollowersCols();
}

// Note: Followers table only has created_at, not updated_at
class FollowersCols extends BaseColsCreatedOnly {
  const FollowersCols();
  static const String followerIdCol = 'follower_id';
  static const String followedIdCol = 'followed_id';

  String get followerId => followerIdCol;
  String get followedId => followedIdCol;
}
