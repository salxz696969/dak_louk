part of domain;

class CreatePostLikeDTO {
  final int userId;
  final int postId;

  CreatePostLikeDTO({
    required this.userId,
    required this.postId,
  });
}

class UpdatePostLikeDTO {
  // Post likes typically don't need updates
  // they are either created or deleted
  UpdatePostLikeDTO();
}
