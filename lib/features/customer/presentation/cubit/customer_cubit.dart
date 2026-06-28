import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/requests/review_request.dart';
import '../../domain/entities/customer_profile_entity.dart';
import '../../domain/entities/customer_statistics_entity.dart';
import '../../domain/entities/handyman_details_entity.dart';
import '../../domain/entities/handyman_list_entity.dart';
import '../../domain/entities/portfolio_item_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/usecases/add_review_usecase.dart';
import '../../domain/usecases/get_featured_handymen_usecase.dart';
import '../../domain/usecases/get_handyman_details_usecase.dart';
import '../../domain/usecases/get_handyman_portfolio_usecase.dart';
import '../../domain/usecases/get_handyman_reviews_usecase.dart';
import '../../domain/usecases/get_handymen_usecase.dart';
import '../../domain/usecases/get_my_reviews_usecase.dart';
import 'customer_state.dart';

import '../../data/models/requests/create_service_request.dart';
import '../../data/models/requests/update_profile_request.dart';

import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/get_requests_usecase.dart';
import '../../domain/usecases/create_request_usecase.dart';
import '../../domain/usecases/get_request_details_usecase.dart';
import '../../domain/usecases/cancel_request_usecase.dart';
import '../../domain/usecases/get_statistics_usecase.dart';

@injectable
class CustomerCubit
    extends Cubit<CustomerState> {
  final GetProfileUseCase
  _getProfileUseCase;

  final UpdateProfileUseCase
  _updateProfileUseCase;

  final GetRequestsUseCase
  _getRequestsUseCase;

  final CreateRequestUseCase
  _createRequestUseCase;

  final GetRequestDetailsUseCase
  _getRequestDetailsUseCase;

  final CancelRequestUseCase
  _cancelRequestUseCase;

  final GetStatisticsUseCase
  _getStatisticsUseCase;

  final GetHandymenUseCase
  _getHandymenUseCase;

  final GetFeaturedHandymenUseCase
  _getFeaturedHandymenUseCase;

  final GetHandymanDetailsUseCase
  _getHandymanDetailsUseCase;

  final GetHandymanPortfolioUseCase
  _getHandymanPortfolioUseCase;

  final GetHandymanReviewsUseCase
  _getHandymanReviewsUseCase;

  final AddReviewUseCase
  _addReviewUseCase;

  final GetMyReviewsUseCase
  _getMyReviewsUseCase;

  List<ReviewEntity> handymanReviews = [];

  List<ReviewEntity> myReviews = [];

  CustomerProfileEntity? customerProfileData;
  CustomerStatisticsEntity? statisticsData;

  List<HandymanListEntity> handymen = [];

  List<HandymanListEntity> featuredHandymen = [];

  HandymanDetailsEntity?handymanDetails;

  List<PortfolioItemEntity> portfolio = [];

  CustomerCubit(
      this._getHandymanReviewsUseCase,
      this._addReviewUseCase,
      this._getMyReviewsUseCase,
      this._getProfileUseCase,
      this._updateProfileUseCase,
      this._getRequestsUseCase,
      this._createRequestUseCase,
      this._getRequestDetailsUseCase,
      this._cancelRequestUseCase,
      this._getStatisticsUseCase,
      this._getHandymenUseCase,
      this._getFeaturedHandymenUseCase,
      this._getHandymanDetailsUseCase,
      this._getHandymanPortfolioUseCase,
      ) : super(
    const CustomerState.initial(),
  );


  Future<void> getMyReviews() async {
    emit(const CustomerState.loading());

    final result =
    await _getMyReviewsUseCase();

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (reviews) {
        myReviews = reviews;

        emit(
          CustomerState.myReviewsLoaded(
            reviews,
          ),
        );
      },
    );
  }

  Future<void> addReview(
      String requestId,
      ReviewRequest request,
      ) async {
    emit(const CustomerState.loading());

    final result =
    await _addReviewUseCase(
      requestId,
      request,
    );

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (_) => emit(
        const CustomerState.message(
          'Review added successfully.',
        ),
      ),
    );
  }

  Future<void> getHandymanReviews(
      String handymanId,
      ) async {
    emit(const CustomerState.loading());

    final result =
    await _getHandymanReviewsUseCase(
      handymanId,
    );

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (reviews) {
        handymanReviews = reviews;

        emit(
          CustomerState.handymanReviewsLoaded(
            reviews,
          ),
        );
      },
    );
  }

  Future<void> getHandymanPortfolio(
      String handymanId,
      ) async {
    emit(const CustomerState.loading());

    final result =
    await _getHandymanPortfolioUseCase(
      handymanId,
    );

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (data) {
        portfolio = data;

        emit(
          CustomerState
              .portfolioLoaded(
            data,
          ),
        );
      },
    );
  }

  Future<void> getHandymanDetails(
      String handymanId,
      ) async {
    emit(const CustomerState.loading());

    final result =
    await _getHandymanDetailsUseCase(
      handymanId,
    );

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (data) {
        handymanDetails = data;

        emit(
          CustomerState
              .handymanDetailsLoaded(
            data,
          ),
        );
      },
    );
  }

  Future<void> getFeaturedHandymen() async {
    emit(const CustomerState.loading());

    final result =
    await _getFeaturedHandymenUseCase();

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (data) {
        featuredHandymen = data;

        emit(
          CustomerState
              .featuredHandymenLoaded(
            data,
          ),
        );
      },
    );
  }

  Future<void> getHandymen({
    String? search,
    String? categoryId,
    bool? availableOnly,
  }) async {
    emit(const CustomerState.loading());
    print('Loading emitted');

    final result = await _getHandymenUseCase(
      search: search,
      categoryId: categoryId,
      availableOnly: availableOnly,
    );

    result.fold(
          (failure) {
        print('Failure emitted');
        emit(CustomerError(failure.message));
      },
          (data) {
        handymen = data;
        print('Loaded emitted: ${handymen.length}');
        emit(CustomerHandymenLoaded(data));
      },
    );
  }

  Future<void> getProfile() async {
    emit(
      const CustomerState.loading(),
    );

    final result = await _getProfileUseCase();

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (profile) {
            customerProfileData = profile;
            emit(CustomerState.profileLoaded(profile,));
          },
    );
  }

  Future<void> updateProfile(UpdateProfileRequest request,) async {
    emit(
      const CustomerState.loading(),
    );

    final result =
    await _updateProfileUseCase(
      request,
    );

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (message) => emit(
        CustomerState.message(
          message,
        ),
      ),
    );
  }

  Future<void> getRequests() async {
    emit(
      const CustomerState.loading(),
    );

    final result = await _getRequestsUseCase();

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (requests) => emit(
        CustomerState.requestsLoaded(
          requests,
        ),
      ),
    );
  }

  Future<void> createRequest(CreateServiceRequest request,) async {
    emit(
      const CustomerState.loading(),
    );

    final result =
    await _createRequestUseCase(
      request,
    );

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (requestId) => emit(
        CustomerState.message(
          requestId,
        ),
      ),
    );
  }

  Future<void> getRequestDetails(String requestId,) async {
    emit(
      const CustomerState.loading(),
    );

    final result =
    await _getRequestDetailsUseCase(
      requestId,
    );

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (request) => emit(
        CustomerState
            .requestDetailsLoaded(
          request,
        ),
      ),
    );
  }

  Future<void> cancelRequest(String requestId,) async {
    emit(
      const CustomerState.loading(),
    );

    final result =
    await _cancelRequestUseCase(
      requestId,
    );

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (_) => emit(
        const CustomerState.message(
          'Request cancelled successfully',
        ),
      ),
    );
  }

  Future<void> getStatistics() async {
    emit(
      const CustomerState.loading(),
    );

    final result =
    await _getStatisticsUseCase();

    result.fold(
          (failure) => emit(
        CustomerState.error(
          failure.message,
        ),
      ),
          (statistics) {
            statisticsData = statistics;
            emit(
              CustomerState.statisticsLoaded(
                statistics,
              ),
            );
          },
    );
  }
}