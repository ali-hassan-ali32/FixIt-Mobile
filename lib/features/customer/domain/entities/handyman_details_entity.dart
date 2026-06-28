class HandymanDetailsEntity {
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

  const HandymanDetailsEntity({
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
}