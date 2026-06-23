import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/customer_profile_entity.dart';
import '../../domain/entities/customer_statistics_entity.dart';
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

  CustomerProfileEntity? profileData;
  CustomerStatisticsEntity? statisticsData;

  CustomerCubit(
      this._getProfileUseCase,
      this._updateProfileUseCase,
      this._getRequestsUseCase,
      this._createRequestUseCase,
      this._getRequestDetailsUseCase,
      this._cancelRequestUseCase,
      this._getStatisticsUseCase,
      ) : super(
    const CustomerState.initial(),
  );

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
            profileData = profile;
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

  Future<void> createRequest(
      CreateServiceRequest request,
      ) async {
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

  Future<void> getRequestDetails(
      String requestId,
      ) async {
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

  Future<void> cancelRequest(
      String requestId,
      ) async {
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