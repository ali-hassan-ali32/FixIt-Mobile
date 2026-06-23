// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lookup_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LookupItemModel _$LookupItemModelFromJson(Map<String, dynamic> json) =>
    LookupItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$LookupItemModelToJson(LookupItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
    };
