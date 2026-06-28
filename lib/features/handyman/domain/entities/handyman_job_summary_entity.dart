class HandymanJobSummaryEntity {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime scheduledDate;
  // final double price;
  final String estimatedDuration;
  final String status;
  final String customerName;

  const HandymanJobSummaryEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.scheduledDate,
    // required this.price,
    required this.estimatedDuration,
    required this.status,
    required this.customerName,
  });
}