part of domain;

class CreateChatRoomDTO {
  final int userId;
  final int merchantId;

  CreateChatRoomDTO({
    required this.userId,
    required this.merchantId,
  });
}

class UpdateChatRoomDTO {
  // Chat rooms typically don't need updates beyond timestamps
  // which are handled automatically
  UpdateChatRoomDTO();
}
