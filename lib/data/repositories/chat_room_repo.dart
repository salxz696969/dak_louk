import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/index.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ChatRoomRepository extends BaseRepository<ChatRoomModel> {
  @override
  String get tableName => Tables.chatRooms.tableName;

  @override
  ChatRoomModel fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      id: map[Tables.chatRooms.cols.id] as int,
      userId: map[Tables.chatRooms.cols.userId] as int,
      merchantId: map[Tables.chatRooms.cols.merchantId] as int,
      createdAt: DateTime.parse(map[Tables.chatRooms.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.chatRooms.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(ChatRoomModel model) {
    return {
      Tables.chatRooms.cols.id: model.id,
      Tables.chatRooms.cols.userId: model.userId,
      Tables.chatRooms.cols.merchantId: model.merchantId,
      Tables.chatRooms.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.chatRooms.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
