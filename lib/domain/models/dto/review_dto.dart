part of domain;

class CreateReviewDTO {
  final int merchantId;
  final String? text;
  final double? rating;

  CreateReviewDTO({required this.merchantId, this.text, this.rating});
}

class UpdateReviewDTO {
  final String? text;
  final double? rating;

  UpdateReviewDTO({this.text, this.rating});
}
