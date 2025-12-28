import 'package:dak_louk/db/repositories/base_repo.dart';
import 'package:dak_louk/models/chat_model.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';

class ChatRepository extends BaseRepository<ChatModel> {
  @override
  String get tableName => Tables.chats.tableName;

  @override
  ChatModel fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map[Tables.chats.cols.id] as int,
      userId: map[Tables.chats.cols.userId] as int,
      text: map[Tables.chats.cols.text] as String,
      chatRoomId: map[Tables.chats.cols.chatRoomId] as int,
      createdAt: map[Tables.chats.cols.createdAt] as DateTime,
      updatedAt: map[Tables.chats.cols.updatedAt] as DateTime,
    );
  }

  @override
  Map<String, dynamic> toMap(ChatModel model) {
    return {
      Tables.chats.cols.id: model.id,
      Tables.chats.cols.userId: model.userId,
      Tables.chats.cols.text: model.text,
      Tables.chats.cols.chatRoomId: model.chatRoomId,
      Tables.chats.cols.createdAt: model.createdAt,
      Tables.chats.cols.updatedAt: model.updatedAt,
    };
  }
}
