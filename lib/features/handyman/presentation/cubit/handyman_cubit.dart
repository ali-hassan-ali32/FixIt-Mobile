import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/requests/add_portfolio_request.dart';
import '../../data/models/requests/update_handyman_profile_request.dart';
import '../../data/models/requests/update_job_status_request.dart';

import '../../domain/entities/handyman_job_summary_entity.dart';
import '../../domain/entities/handyman_portfolio_entity.dart';
import '../../domain/entities/handyman_profile_entity.dart';
import '../../domain/entities/handyman_statistics_entity.dart';
import '../../domain/usecases/add_portfolio_usecase.dart';
import '../../domain/usecases/delete_portfolio_usecase.dart';
import '../../domain/usecases/get_handyman_profile_usecase.dart';
import '../../domain/usecases/get_handyman_statistics_usecase.dart';
import '../../domain/usecases/get_portfolio_usecase.dart';
import '../../domain/usecases/update_handyman_profile_usecase.dart';

import '../../domain/usecases/get_jobs_usecase.dart';
import '../../domain/usecases/get_job_details_usecase.dart';
import '../../domain/usecases/update_job_status_usecase.dart';

import '../../domain/usecases/get_reviews_usecase.dart';
import '../../domain/usecases/get_available_requests_usecase.dart';

import 'handyman_state.dart';

@injectable
class HandymanCubit extends Cubit<HandymanState> {
  final GetHandymanProfileUseCase getProfileUseCase;
  final UpdateHandymanProfileUseCase updateProfileUseCase;

  final GetJobsUseCase getJobsUseCase;
  final GetJobDetailsUseCase getJobDetailsUseCase;
  final UpdateJobStatusUseCase updateJobStatusUseCase;

  final GetReviewsUseCase getReviewsUseCase;
  final GetAvailableRequestsUseCase getAvailableRequestsUseCase;

  final GetHandymanStatisticsUseCase getHandymanStatisticsUseCase;
  final GetPortfolioUseCase getPortfolioUseCase;
  final AddPortfolioUseCase addPortfolioUseCase;
  final DeletePortfolioUseCase deletePortfolioUseCase;

  // ── Cached data (single source of truth) ──────────────────
  HandymanProfileEntity?         handymanProfileData;
  HandymanStatisticsEntity?      statisticsData;
  List<HandymanJobSummaryEntity> jobsData              = [];
  List<HandymanJobSummaryEntity> availableRequestsData = [];
  List<HandymanPortfolioEntity>  portfolioData         = [];
  bool                           isAvailable           = true;

  HandymanCubit(
    this.getProfileUseCase,
    this.updateProfileUseCase,
    this.getJobsUseCase,
    this.getJobDetailsUseCase,
    this.updateJobStatusUseCase,
    this.getReviewsUseCase,
    this.getAvailableRequestsUseCase,
    this.getHandymanStatisticsUseCase,
    this.getPortfolioUseCase,
    this.addPortfolioUseCase,
    this.deletePortfolioUseCase,
  ) : super(const HandymanState.initial());

  // ══════════════════════════════════════════════════════════
  // loadHome — single entry point for the Home screen.
  // Fires all 4 fetches in parallel, caches results, then
  // emits homeUpdated ONCE → zero intermediate redraws.
  // ══════════════════════════════════════════════════════════
  Future<void> loadHome() async {
    emit(const HandymanState.loading());

    await Future.wait([
      _fetchProfile(),
      _fetchStatistics(),
      _fetchAvailableRequests(),
      _fetchJobs(),
    ]);

    emit(const HandymanState.homeUpdated());
  }

  // ── Private silent fetchers (no state emits) ──────────────

  Future<void> _fetchProfile() async {
    final result = await getProfileUseCase();
    result.fold(
      (_) {},
      (profile) {
        handymanProfileData = profile;
        isAvailable = profile.isAvailable;
      },
    );
  }

  Future<void> _fetchStatistics() async {
    final result = await getHandymanStatisticsUseCase();
    result.fold(
      (_) {},
      (stats) => statisticsData = stats,
    );
  }

  Future<void> _fetchAvailableRequests() async {
    final result = await getAvailableRequestsUseCase();
    result.fold(
      (_) {},
      (requests) => availableRequestsData = requests,
    );
  }

  Future<void> _fetchJobs() async {
    final result = await getJobsUseCase();
    result.fold(
      (_) {},
      (jobs) => jobsData = jobs,
    );
  }

  // ══════════════════════════════════════════════════════════
  // Public individual methods — used by other screens that
  // still need feature-specific states (profile page, jobs
  // page, statistics page, etc.).
  // ══════════════════════════════════════════════════════════

  Future<void> getProfile() async {
    emit(const HandymanState.loading());

    final result = await getProfileUseCase();

    result.fold(
      (failure) => emit(HandymanState.error(failure.message)),
      (profile) {
        handymanProfileData = profile;
        isAvailable = profile.isAvailable;
        emit(HandymanState.profileLoaded(profile));
      },
    );
  }

  Future<void> updateProfile(UpdateHandymanProfileRequest request) async {
    emit(const HandymanState.loading());

    final result = await updateProfileUseCase(request);

    result.fold(
      (failure) => emit(HandymanState.error(failure.message)),
      (_) => emit(const HandymanState.message('Profile updated successfully')),
    );
  }

  Future<void> getJobs() async {
    emit(const HandymanState.loading());

    final result = await getJobsUseCase();

    result.fold(
      (failure) => emit(HandymanState.error(failure.message)),
      (jobs) {
        jobsData = jobs;
        emit(HandymanState.jobsLoaded(jobs));
      },
    );
  }

  Future<void> getJobDetails(String id) async {
    emit(const HandymanState.loading());

    final result = await getJobDetailsUseCase(id);

    result.fold(
      (failure) => emit(HandymanState.error(failure.message)),
      (job)     => emit(HandymanState.jobDetailsLoaded(job)),
    );
  }

  Future<void> updateJobStatus(String id, UpdateJobStatusRequest request) async {
    final result = await updateJobStatusUseCase(id, request);

    result.fold(
      (failure) => emit(HandymanState.error(failure.message)),
      (_) => emit(const HandymanState.message('Job status updated successfully')),
    );
  }

  Future<void> getReviews() async {
    emit(const HandymanState.loading());

    final result = await getReviewsUseCase();

    result.fold(
      (failure) => emit(HandymanState.error(failure.message)),
      (reviews) => emit(HandymanState.reviewsLoaded(reviews)),
    );
  }

  Future<void> getAvailableRequests() async {
    emit(const HandymanState.loading());

    final result = await getAvailableRequestsUseCase();

    result.fold(
      (failure) => emit(HandymanState.error(failure.message)),
      (requests) {
        availableRequestsData = requests;
        emit(HandymanState.availableRequestsLoaded(requests));
      },
    );
  }

  Future<void> getStatistics() async {
    emit(const HandymanState.loading());

    final result = await getHandymanStatisticsUseCase();

    result.fold(
      (failure) => emit(HandymanState.error(failure.message)),
      (statistics) {
        statisticsData = statistics;
        emit(HandymanState.statisticsLoaded(statistics));
      },
    );
  }

  Future<void> getPortfolio() async {
    emit(const HandymanState.loading());

    final result = await getPortfolioUseCase();

    result.fold(
      (failure) => emit(HandymanState.error(failure.message)),
      (portfolio) {
        portfolioData = portfolio;
        emit(HandymanState.portfolioLoaded(portfolio));
      },
    );
  }

  Future<void> addPortfolio(AddPortfolioRequest request) async {
    emit(const HandymanState.loading());

    final result = await addPortfolioUseCase(request);

    result.fold(
      (failure) => emit(HandymanState.error(failure.message)),
      (_) => emit(const HandymanState.message('Portfolio item added successfully')),
    );
  }

  Future<void> deletePortfolio(String id) async {
    final result = await deletePortfolioUseCase(id);

    result.fold(
      (failure) => emit(HandymanState.error(failure.message)),
      (_) => emit(const HandymanState.message('Portfolio item deleted successfully')),
    );
  }
}