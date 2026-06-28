import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/handyman_portfolio_entity.dart';
import '../../domain/entities/handyman_profile_entity.dart';
import '../../domain/entities/handyman_job_summary_entity.dart';
import '../../domain/entities/handyman_job_details_entity.dart';
import '../../domain/entities/handyman_review_entity.dart';
import '../../domain/entities/handyman_statistics_entity.dart';

part 'handyman_state.freezed.dart';

@freezed
class HandymanState with _$HandymanState {
  const factory HandymanState.initial() =
  HandymanInitial;

  const factory HandymanState.loading() =
  HandymanLoading;

  const factory HandymanState.profileLoaded(
      HandymanProfileEntity profile,
      ) = HandymanProfileLoaded;

  const factory HandymanState.jobsLoaded(
      List<HandymanJobSummaryEntity> jobs,
      ) = HandymanJobsLoaded;

  const factory HandymanState.jobDetailsLoaded(
      HandymanJobDetailsEntity job,
      ) = HandymanJobDetailsLoaded;

  const factory HandymanState.reviewsLoaded(
      List<HandymanReviewEntity> reviews,
      ) = HandymanReviewsLoaded;

  const factory HandymanState.availableRequestsLoaded(
      List<HandymanJobSummaryEntity> requests,
      ) = HandymanAvailableRequestsLoaded;

  const factory HandymanState.message(
      String message,
      ) = HandymanMessage;

  const factory HandymanState.error(
      String message,
      ) = HandymanError;


  const factory HandymanState.statisticsLoaded(
      HandymanStatisticsEntity statistics,
      ) = HandymanStatisticsLoaded;

  const factory HandymanState.portfolioLoaded(
      List<HandymanPortfolioEntity> portfolio,
      ) = HandymanPortfolioLoaded;

  /// Emitted once after loadHome() finishes all 4 parallel fetches.
  /// The Home screen only rebuilds on this state — no intermediate flicker.
  const factory HandymanState.homeUpdated() = HandymanHomeUpdated;
}