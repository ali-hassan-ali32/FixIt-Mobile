import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/lookup_item_entity.dart';

part 'lookup_item_model.g.dart';

@JsonSerializable()
class LookupItemModel {

  final String id;
  final String name;
  final String? icon;

  const LookupItemModel({
    required this.id,
    required this.name,
    this.icon,
  });

  factory LookupItemModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$LookupItemModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$LookupItemModelToJson(this);

  LookupItemEntity toEntity() {
    return LookupItemEntity(
      id: id,
      name: name,
      icon: icon,
    );
  }
}