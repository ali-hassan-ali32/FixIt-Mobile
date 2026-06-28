
import '../../../domain/entities/review_entity.dart';

class ReviewModel {
  final int rating;
  final String comment;
  final String customerName;
  final DateTime createdAt;

  const ReviewModel({
    required this.rating,
    required this.comment,
    required this.customerName,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ReviewModel(
      rating: json['rating'],
      comment: json['comment'],
      customerName: json['customerName'],
      createdAt: DateTime.parse(
        json['createdAt'],
      ),
    );
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      rating: rating,
      comment: comment,
      customerName: customerName,
      createdAt: createdAt,
    );
  }
}