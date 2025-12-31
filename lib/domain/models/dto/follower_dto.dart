part of domain;

class CreateFollowerDTO {
  final int followedId;

  CreateFollowerDTO({required this.followedId});
}

class UpdateFollowerDTO {
  // Followers typically don't need updates
  // they are either created or deleted
  UpdateFollowerDTO();
}
