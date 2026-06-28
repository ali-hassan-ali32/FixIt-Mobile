class HandymanReviewEntity {
  final num rating;
  final String comment;
  final String customerName;
  final DateTime createdAt;

  const HandymanReviewEntity({
    required this.rating,
    required this.comment,
    required this.customerName,
    required this.createdAt,
  });
}