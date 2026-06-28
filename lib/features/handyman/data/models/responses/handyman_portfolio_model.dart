import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/handyman_portfolio_entity.dart';

part 'handyman_portfolio_model.g.dart';

@JsonSerializable()
class HandymanPortfolioModel {
  final String id;
  final String? imageUrl;
  final String? title;
  final String? description;

  const HandymanPortfolioModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
  });

  factory HandymanPortfolioModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$HandymanPortfolioModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HandymanPortfolioModelToJson(this);

  HandymanPortfolioEntity toEntity() {
    return HandymanPortfolioEntity(
      id: id,
      imageUrl: imageUrl ?? '',
      title: title ?? 'بدون عنوان',
      description: description ?? 'لا يوجد وصف',
    );
  }
}