part of domain;

class ChatRoomModel extends Cacheable {
  final int id;
  final int userId;
  final int merchantId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatRoomModel({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.createdAt,
    required this.updatedAt,
  });
}
