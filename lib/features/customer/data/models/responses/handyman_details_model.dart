import '../../../domain/entities/handyman_details_entity.dart';

class HandymanDetailsModel {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final String category;
  final int yearsOfExperience;
  final double basePrice;
  final bool isAvailable;
  final String city;
  final String region;
  final int reviewsCount;
  final double averageRating;

  const HandymanDetailsModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    required this.category,
    required this.yearsOfExperience,
    required this.basePrice,
    required this.isAvailable,
    required this.city,
    required this.region,
    required this.reviewsCount,
    required this.averageRating,
  });

  factory HandymanDetailsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return HandymanDetailsModel(
      id: json['id'],
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      category: json['category'],
      yearsOfExperience: json['yearsOfExperience'],
      basePrice: (json['basePrice'] as num).toDouble(),
      isAvailable: json['isAvailable'],
      city: json['city'],
      region: json['region'],
      reviewsCount: json['reviewsCount'],
      averageRating: (json['averageRating'] as num).toDouble(),
    );
  }

  HandymanDetailsEntity toEntity() {
    return HandymanDetailsEntity(
      id: id,
      fullName: fullName,
      avatarUrl: avatarUrl,
      bio: bio,
      category: category,
      yearsOfExperience: yearsOfExperience,
      basePrice: basePrice,
      isAvailable: isAvailable,
      city: city,
      region: region,
      reviewsCount: reviewsCount,
      averageRating: averageRating,
    );
  }
}