part of models;

class ChatRoomModel extends Cacheable {
  final int id;
  final int userId;
  final int merchantId;
  final String createdAt;
  final String updatedAt;

  ChatRoomModel({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.createdAt,
    required this.updatedAt,
  });
}
