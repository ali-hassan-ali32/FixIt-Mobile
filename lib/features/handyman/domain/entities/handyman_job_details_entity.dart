class HandymanJobDetailsEntity {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime scheduledDate;
  // final double price;
  final int estimatedDurationInMinutes;
  final String status;
  final String customerName;
  final List<String> images;

  const HandymanJobDetailsEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.scheduledDate,
    // required this.price,
    required this.estimatedDurationInMinutes,
    required this.status,
    required this.customerName,
    required this.images,
  });
}