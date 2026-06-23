class CustomerRequestDetailsEntity {
  final String id;
  final String? handymanName;
  final String title;
  final String description;
  final String status;
  final String address;
  final DateTime scheduledAt;
  final List<String> imageUrls;
  final DateTime createdAt;

  const CustomerRequestDetailsEntity({
    required this.id,
    required this.handymanName,
    required this.title,
    required this.description,
    required this.status,
    required this.address,
    required this.scheduledAt,
    required this.imageUrls,
    required this.createdAt,
  });
}