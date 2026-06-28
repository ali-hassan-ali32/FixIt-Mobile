import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_portfolio_request.g.dart';

@JsonSerializable()
class AddPortfolioRequest {
  final String imageUrl;
  final String? title;
  final String? description;

  const AddPortfolioRequest({
    required this.imageUrl,
    this.title,
    this.description,
  });

  factory AddPortfolioRequest.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$AddPortfolioRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AddPortfolioRequestToJson(this);
}