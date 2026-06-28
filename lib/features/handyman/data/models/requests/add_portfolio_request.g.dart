// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_portfolio_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddPortfolioRequest _$AddPortfolioRequestFromJson(Map<String, dynamic> json) =>
    AddPortfolioRequest(
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$AddPortfolioRequestToJson(
  AddPortfolioRequest instance,
) => <String, dynamic>{
  'imageUrl': instance.imageUrl,
  'title': instance.title,
  'description': instance.description,
};
