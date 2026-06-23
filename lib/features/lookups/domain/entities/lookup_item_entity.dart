class LookupItemEntity {
  final String id;
  final String name;
  final String? icon;

  const LookupItemEntity({
    required this.id,
    required this.name,
    this.icon,
  });
}