class CustomerProfileEntity {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String? avatar;
  final String address;
  final bool isVerified;
  final DateTime memberSince;

  const CustomerProfileEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.avatar,
    required this.address,
    required this.isVerified,
    required this.memberSince,
  });
}