part of domain;

class CreatePostSaveDTO {
  final int userId;
  final int postId;

  CreatePostSaveDTO({
    required this.userId,
    required this.postId,
  });
}

class UpdatePostSaveDTO {
  // Post saves typically don't need updates
  // they are either created or deleted
  UpdatePostSaveDTO();
}
