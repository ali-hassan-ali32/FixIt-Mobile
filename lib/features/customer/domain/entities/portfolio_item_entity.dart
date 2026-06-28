class PortfolioItemEntity {
  final String id;
  final String imageUrl;
  final String? title;
  final String? description;

  const PortfolioItemEntity({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
  });
}