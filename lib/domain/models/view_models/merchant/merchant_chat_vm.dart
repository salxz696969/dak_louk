part of models;

class MerchantChatVM extends Cacheable {
  final int id;
  final bool isMine;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantChatVM({
    required this.id,
    required this.text,
    required this.isMine,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantChatVM.fromRaw(ChatModel raw, {required bool isMine}) {
    return MerchantChatVM(
      id: raw.id,
      isMine: isMine,
      text: raw.text,
      createdAt: DateTime.parse(raw.createdAt),
      updatedAt: DateTime.parse(raw.updatedAt),
    );
  }
}
