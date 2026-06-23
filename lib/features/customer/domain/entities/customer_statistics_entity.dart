class CustomerStatisticsEntity {
  final int totalRequests;
  final int pendingRequests;
  final int completedRequests;
  final int cancelledRequests;
  final int totalReviews;

  const CustomerStatisticsEntity({
    required this.totalRequests,
    required this.pendingRequests,
    required this.completedRequests,
    required this.cancelledRequests,
    required this.totalReviews,
  });
}