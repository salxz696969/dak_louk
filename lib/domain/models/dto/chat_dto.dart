part of domain;

class CreateChatDTO {
  final int chatRoomId;
  final int senderId;
  final String text;

  CreateChatDTO({
    required this.chatRoomId,
    required this.senderId,
    required this.text,
  });
}

class UpdateChatDTO {
  final String? text;

  UpdateChatDTO({
    this.text,
  });
}
