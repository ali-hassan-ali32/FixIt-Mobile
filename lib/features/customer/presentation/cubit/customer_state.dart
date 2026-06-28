import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/customer_profile_entity.dart';
import '../../domain/entities/customer_request_details_entity.dart';
import '../../domain/entities/customer_request_summary_entity.dart';
import '../../domain/entities/customer_statistics_entity.dart';
import '../../domain/entities/handyman_details_entity.dart';
import '../../domain/entities/handyman_list_entity.dart';
import '../../domain/entities/portfolio_item_entity.dart';
import '../../domain/entities/review_entity.dart';

part 'customer_state.freezed.dart';

@freezed
class CustomerState with _$CustomerState {
  const factory CustomerState.initial() =
  CustomerInitial;

  const factory CustomerState.loading() =
  CustomerLoading;

  const factory CustomerState.profileLoaded(
      CustomerProfileEntity profile,
      ) = CustomerProfileLoaded;

  const factory CustomerState.requestsLoaded(
      List<CustomerRequestSummaryEntity>
      requests,
      ) = CustomerRequestsLoaded;

  const factory CustomerState.requestDetailsLoaded(
      CustomerRequestDetailsEntity
      request,
      ) = CustomerRequestDetailsLoaded;

  const factory CustomerState.statisticsLoaded(
      CustomerStatisticsEntity
      statistics,
      ) = CustomerStatisticsLoaded;

  const factory CustomerState.message(
      String message,
      ) = CustomerMessage;

  const factory CustomerState.error(
      String message,
      ) = CustomerError;

  const factory CustomerState.handymenLoaded(
      List<HandymanListEntity> handymen,
      ) = CustomerHandymenLoaded;

  const factory CustomerState.featuredHandymenLoaded(
      List<HandymanListEntity> handymen,
      ) = CustomerFeaturedHandymenLoaded;

  const factory CustomerState.handymanDetailsLoaded(
      HandymanDetailsEntity handyman,
      ) = CustomerHandymanDetailsLoaded;

  const factory CustomerState.portfolioLoaded(
      List<PortfolioItemEntity> portfolio,
      ) = CustomerPortfolioLoaded;

  const factory CustomerState.handymanReviewsLoaded(
      List<ReviewEntity> reviews,
      ) = CustomerHandymanReviewsLoaded;

  const factory CustomerState.myReviewsLoaded(
      List<ReviewEntity> reviews,
      ) = CustomerMyReviewsLoaded;
}