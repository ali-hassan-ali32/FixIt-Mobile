class AuthUser {
  final String id;
  final String displayName;
  final String phoneNumber;
  final String role;
  final String token;

  const AuthUser({
    required this.id,
    required this.displayName,
    required this.phoneNumber,
    required this.role,
    required this.token,
  });
}