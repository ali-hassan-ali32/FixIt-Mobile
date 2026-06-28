class HandymanListEntity {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String category;
  final int yearsOfExperience;
  final double basePrice;
  final bool isAvailable;
  final double rating;
  final int reviewCount;

  const HandymanListEntity({
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
}