class CustomerRequestSummaryEntity {
  final String id;
  final String title;
  final String status;
  final String? handymanName;
  final DateTime scheduledAt;
  final String location;

  const CustomerRequestSummaryEntity({
    required this.id,
    required this.title,
    required this.status,
    required this.handymanName,
    required this.scheduledAt,
    required this.location,
  });
}