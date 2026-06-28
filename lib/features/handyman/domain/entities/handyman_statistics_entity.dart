class HandymanStatisticsEntity {
  final int completedJobs;
  final int activeJobs;
  final int pendingJobs;
  final int totalReviews;
  final double averageRating;

  const HandymanStatisticsEntity({
    required this.completedJobs,
    required this.activeJobs,
    required this.pendingJobs,
    required this.totalReviews,
    required this.averageRating,
  });
}