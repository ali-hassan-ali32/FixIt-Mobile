class ReviewEntity {
  final int rating;
  final String comment;
  final String customerName;
  final DateTime createdAt;

  const ReviewEntity({
    required this.rating,
    required this.comment,
    required this.customerName,
    required this.createdAt,
  });
}