part of domain;

class CreateChatDTO {
  final int chatRoomId;
  final String text;

  CreateChatDTO({required this.chatRoomId, required this.text});
}

class UpdateChatDTO {
  final String? text;

  UpdateChatDTO({this.text});
}
