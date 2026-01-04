import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/tables/tables.dart';

class ChatRepository extends BaseRepository<ChatModel> {
  @override
  String get tableName => Tables.chats.tableName;

  @override
  ChatModel fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map[Tables.chats.cols.id] as int,
      senderId: map[Tables.chats.cols.senderId] as int,
      text: map[Tables.chats.cols.text] as String,
      chatRoomId: map[Tables.chatRooms.cols.id] as int,
      createdAt: map[Tables.chats.cols.createdAt] as String,
      updatedAt: map[Tables.chats.cols.updatedAt] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(ChatModel model) {
    return {
      Tables.chats.cols.id: model.id,
      Tables.chats.cols.senderId: model.senderId,
      Tables.chats.cols.text: model.text,
      Tables.chats.cols.chatRoomId: model.chatRoomId,
      Tables.chats.cols.createdAt: model.createdAt,
      Tables.chats.cols.updatedAt: model.updatedAt,
    };
  }
}
