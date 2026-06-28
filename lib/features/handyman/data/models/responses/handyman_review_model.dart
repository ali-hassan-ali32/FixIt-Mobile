import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/handyman_review_entity.dart';

part 'handyman_review_model.g.dart';

@JsonSerializable()
class HandymanReviewModel {
  final num? rating;
  final String? comment;
  final String? customerName;
  final DateTime? createdAt;

  const HandymanReviewModel({
    this.rating,
    this.comment,
    this.customerName,
    this.createdAt,
  });

  factory HandymanReviewModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$HandymanReviewModelFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$HandymanReviewModelToJson(
        this,
      );

  HandymanReviewEntity toEntity() {
    return HandymanReviewEntity(
      rating: rating ?? 0.0,
      comment: comment ?? 'No Comment',
      customerName: customerName ?? 'No Name',
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}