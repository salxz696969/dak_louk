enum ProgressStatus {
  waiting('waiting'),
  accepted('accepted'),
  delivering('delivering'),
  completed('completed'),
  cancelled('cancelled'),
;
  final String name;
  const ProgressStatus(this.name);
}
