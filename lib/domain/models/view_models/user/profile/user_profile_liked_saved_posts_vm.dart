part of models;

class UserProfileLikedSavedPostsVM extends Cacheable {
  final id;
  final String imageUrl;
  final String caption;

  UserProfileLikedSavedPostsVM({
    required this.id,
    required this.imageUrl,
    required this.caption,
  });
}
