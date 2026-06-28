import '../../../domain/entities/handyman_list_entity.dart';

class HandymanListModel {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String category;
  final int yearsOfExperience;
  final double basePrice;
  final bool isAvailable;
  final double rating;
  final int reviewCount;

  const HandymanListModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.category,
    required this.yearsOfExperience,
    required this.basePrice,
    required this.isAvailable,
    required this.rating,
    required this.reviewCount,
  });

  factory HandymanListModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return HandymanListModel(
      id: json['id'],
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'],
      category: json['category'],
      yearsOfExperience: json['yearsOfExperience'],
      basePrice: (json['basePrice'] as num).toDouble(),
      isAvailable: json['isAvailable'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }

  HandymanListEntity toEntity() {
    return HandymanListEntity(
      id: id,
      fullName: fullName,
      avatarUrl: avatarUrl,
      category: category,
      yearsOfExperience: yearsOfExperience,
      basePrice: basePrice,
      isAvailable: isAvailable,
      rating: rating,
      reviewCount: reviewCount,
    );
  }
}