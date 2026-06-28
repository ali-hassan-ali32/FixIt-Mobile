// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handyman_portfolio_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandymanPortfolioModel _$HandymanPortfolioModelFromJson(
  Map<String, dynamic> json,
) => HandymanPortfolioModel(
  id: json['id'] as String,
  imageUrl: json['imageUrl'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$HandymanPortfolioModelToJson(
  HandymanPortfolioModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'imageUrl': instance.imageUrl,
  'title': instance.title,
  'description': instance.description,
};
