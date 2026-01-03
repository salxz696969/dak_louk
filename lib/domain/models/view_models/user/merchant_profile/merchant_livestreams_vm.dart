part of models;

class MerchantLivestreamsVM {
  final int id;
  final String title;
  final String thumbnailUrl;

  MerchantLivestreamsVM({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
  });

  factory MerchantLivestreamsVM.fromRaw(
    LiveStreamModel raw, {
    required List<PromoMediaModel> promoMedias,
  }) {
    return MerchantLivestreamsVM(
      id: raw.id,
      title: raw.title,
      thumbnailUrl: raw.thumbnailUrl ?? '',
    );
  }
}
