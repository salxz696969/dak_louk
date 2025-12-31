part of domain;

class CreateFollowerDTO {
  final int followerId;
  final int followedId;

  CreateFollowerDTO({
    required this.followerId,
    required this.followedId,
  });
}

class UpdateFollowerDTO {
  // Followers typically don't need updates
  // they are either created or deleted
  UpdateFollowerDTO();
}
