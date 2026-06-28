class HandymanProfileEntity {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final String? bio;
  final double basePrice;
  final int yearsOfExperience;
  final bool isAvailable;
  final String category;
  final String city;
  final String region;

  const HandymanProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
    this.bio,
    required this.basePrice,
    required this.yearsOfExperience,
    required this.isAvailable,
    required this.category,
    required this.city,
    required this.region,
  });
}