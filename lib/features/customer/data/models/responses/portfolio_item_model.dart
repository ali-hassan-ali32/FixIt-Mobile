import '../../../domain/entities/portfolio_item_entity.dart';

class PortfolioItemModel {
  final String id;
  final String imageUrl;
  final String? title;
  final String? description;

  const PortfolioItemModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
  });

  factory PortfolioItemModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PortfolioItemModel(
      id: json['id'],
      imageUrl: json['imageUrl'],
      title: json['title'],
      description: json['description'],
    );
  }

  PortfolioItemEntity toEntity() {
    return PortfolioItemEntity(
      id: id,
      imageUrl: imageUrl,
      title: title,
      description: description,
    );
  }
}