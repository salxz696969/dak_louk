part of domain;

class CreatePostLikeDTO {
  final int postId;

  CreatePostLikeDTO({required this.postId});
}

class UpdatePostLikeDTO {
  // Post likes typically don't need updates
  // they are either created or deleted
  UpdatePostLikeDTO();
}
