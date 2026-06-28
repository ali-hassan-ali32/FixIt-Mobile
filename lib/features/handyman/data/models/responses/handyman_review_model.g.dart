// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handyman_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandymanReviewModel _$HandymanReviewModelFromJson(Map<String, dynamic> json) =>
    HandymanReviewModel(
      rating: json['rating'] as num?,
      comment: json['comment'] as String?,
      customerName: json['customerName'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$HandymanReviewModelToJson(
  HandymanReviewModel instance,
) => <String, dynamic>{
  'rating': instance.rating,
  'comment': instance.comment,
  'customerName': instance.customerName,
  'createdAt': instance.createdAt?.toIso8601String(),
};
