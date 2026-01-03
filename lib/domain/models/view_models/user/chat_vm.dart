part of models;

class ChatVM extends Cacheable {
  final int id;
  final bool isMine;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatVM({
    required this.id,
    required this.text,
    required this.isMine,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatVM.fromRaw(ChatModel raw, {required bool isMine}) {
    return ChatVM(
      id: raw.id,
      isMine: isMine,
      text: raw.text,
      createdAt: DateTime.parse(raw.createdAt),
      updatedAt: DateTime.parse(raw.updatedAt),
    );
  }
}
