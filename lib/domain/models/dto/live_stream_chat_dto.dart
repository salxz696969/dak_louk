part of domain;

class CreateLiveStreamChatDTO {
  final int liveStreamId;
  final String text;

  CreateLiveStreamChatDTO({required this.liveStreamId, required this.text});
}

class UpdateLiveStreamChatDTO {
  final String? text;

  UpdateLiveStreamChatDTO({this.text});
}
