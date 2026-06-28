// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../core/network/auth_interceptor.dart' as _i388;
import '../../core/network/dio_factory.dart' as _i282;
import '../../core/network/network_info.dart' as _i892;
import '../../core/storage/secure_storage_service.dart' as _i64;
import '../../features/auth/api/services/auth_api_service.dart' as _i711;
import '../../features/auth/data/datasource/auth_remote_data_source.dart'
    as _i24;
import '../../features/auth/data/datasource/auth_remote_data_source_impl.dart'
    as _i68;
import '../../features/auth/data/repository/auth_repository_impl.dart' as _i409;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/forgot_password_usecase.dart'
    as _i560;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/register_customer_usecase.dart'
    as _i1063;
import '../../features/auth/domain/usecases/register_handyman_usecase.dart'
    as _i302;
import '../../features/auth/domain/usecases/reset_password_usecase.dart'
    as _i474;
import '../../features/auth/domain/usecases/verify_otp_usecase.dart' as _i503;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/customer/api/services/customer_api_service.dart'
    as _i551;
import '../../features/customer/data/datasource/customer_remote_data_source.dart'
    as _i379;
import '../../features/customer/data/datasource/customer_remote_data_source_impl.dart'
    as _i613;
import '../../features/customer/data/repository/customer_repository_impl.dart'
    as _i180;
import '../../features/customer/domain/repositories/customer_repository.dart'
    as _i547;
import '../../features/customer/domain/usecases/add_review_usecase.dart'
    as _i348;
import '../../features/customer/domain/usecases/cancel_request_usecase.dart'
    as _i948;
import '../../features/customer/domain/usecases/create_request_usecase.dart'
    as _i556;
import '../../features/customer/domain/usecases/get_featured_handymen_usecase.dart'
    as _i109;
import '../../features/customer/domain/usecases/get_handyman_details_usecase.dart'
    as _i1043;
import '../../features/customer/domain/usecases/get_handyman_portfolio_usecase.dart'
    as _i650;
import '../../features/customer/domain/usecases/get_handyman_reviews_usecase.dart'
    as _i127;
import '../../features/customer/domain/usecases/get_handymen_usecase.dart'
    as _i274;
import '../../features/customer/domain/usecases/get_my_reviews_usecase.dart'
    as _i75;
import '../../features/customer/domain/usecases/get_profile_usecase.dart'
    as _i476;
import '../../features/customer/domain/usecases/get_request_details_usecase.dart'
    as _i1035;
import '../../features/customer/domain/usecases/get_requests_usecase.dart'
    as _i756;
import '../../features/customer/domain/usecases/get_statistics_usecase.dart'
    as _i699;
import '../../features/customer/domain/usecases/update_profile_usecase.dart'
    as _i488;
import '../../features/customer/presentation/cubit/customer_cubit.dart'
    as _i643;
import '../../features/handyman/api/services/handyman_api_service.dart'
    as _i850;
import '../../features/handyman/data/datasource/handyman_remote_data_source.dart'
    as _i476;
import '../../features/handyman/data/datasource/handyman_remote_data_source_impl.dart'
    as _i1000;
import '../../features/handyman/data/repository/handyman_repository_impl.dart'
    as _i316;
import '../../features/handyman/domain/repositories/handyman_repository.dart'
    as _i761;
import '../../features/handyman/domain/usecases/add_portfolio_usecase.dart'
    as _i373;
import '../../features/handyman/domain/usecases/delete_portfolio_usecase.dart'
    as _i95;
import '../../features/handyman/domain/usecases/get_available_requests_usecase.dart'
    as _i8;
import '../../features/handyman/domain/usecases/get_handyman_profile_usecase.dart'
    as _i793;
import '../../features/handyman/domain/usecases/get_handyman_statistics_usecase.dart'
    as _i920;
import '../../features/handyman/domain/usecases/get_job_details_usecase.dart'
    as _i227;
import '../../features/handyman/domain/usecases/get_jobs_usecase.dart' as _i783;
import '../../features/handyman/domain/usecases/get_portfolio_usecase.dart'
    as _i1059;
import '../../features/handyman/domain/usecases/get_reviews_usecase.dart'
    as _i718;
import '../../features/handyman/domain/usecases/update_handyman_profile_usecase.dart'
    as _i651;
import '../../features/handyman/domain/usecases/update_job_status_usecase.dart'
    as _i651;
import '../../features/handyman/presentation/cubit/handyman_cubit.dart' as _i10;
import '../../features/lookups/api/services/lookup_api_service.dart' as _i633;
import '../../features/lookups/data/repository/lookup_repository_impl.dart'
    as _i83;
import '../../features/lookups/domain/repositories/lookup_repository.dart'
    as _i875;
import '../../features/lookups/presentation/cubit/lookup_cubit.dart' as _i1031;
import '../../features/notifications/api/services/notification_api_service.dart'
    as _i132;
import '../../features/notifications/data/datasources/notification_remote_data_source.dart'
    as _i757;
import '../../features/notifications/data/datasources/notification_remote_data_source_impl.dart'
    as _i655;
import '../../features/notifications/data/repositories/notification_repository_impl.dart'
    as _i361;
import '../../features/notifications/domain/repository/notification_repository.dart'
    as _i1068;
import '../../features/notifications/domain/usecases/delete_notification_usecase.dart'
    as _i169;
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart'
    as _i587;
import '../../features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i730;
import '../../features/notifications/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i889;
import '../../features/notifications/presentaions/cubit/notification_cubit.dart'
    as _i335;
import '../providers/app_config_provider.dart' as _i56;
import 'module/auth_service_module.dart' as _i326;
import 'module/lookup_module.dart' as _i452;
import 'module/network_module.dart' as _i881;
import 'module/secure_storage_module.dart' as _i621;
import 'module/shared_preferences_module.dart' as _i309;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final sharedPreferencesModule = _$SharedPreferencesModule();
    final secureStorageModule = _$SecureStorageModule();
    final networkModule = _$NetworkModule();
    final authServiceModule = _$AuthServiceModule();
    final lookupModule = _$LookupModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.provideSharedPreferences(),
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.secureStorage,
    );
    gh.lazySingleton<_i892.NetworkInfo>(() => const _i892.NetworkInfoImpl());
    gh.lazySingleton<_i56.AppConfigProvider>(
      () => _i56.AppConfigProvider(
        sharedPreferences: gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i64.SecureStorageService>(
      () => _i64.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i388.AuthInterceptor>(
      () => _i388.AuthInterceptor(gh<_i64.SecureStorageService>()),
    );
    gh.lazySingleton<_i282.DioFactory>(
      () => _i282.DioFactory(gh<_i388.AuthInterceptor>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(gh<_i282.DioFactory>()),
    );
    gh.lazySingleton<_i711.AuthApiService>(
      () => authServiceModule.authApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i633.LookupApiService>(
      () => lookupModule.lookupApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i551.CustomerApiService>(
      () => networkModule.customerApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i850.HandymanApiService>(
      () => networkModule.handymanApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i132.NotificationApiService>(
      () => networkModule.notificationApiService(gh<_i361.Dio>()),
    );
    gh.factory<_i379.CustomerRemoteDataSource>(
      () => _i613.CustomerRemoteDataSourceImpl(gh<_i551.CustomerApiService>()),
    );
    gh.factory<_i547.CustomerRepository>(
      () => _i180.CustomerRepositoryImpl(gh<_i379.CustomerRemoteDataSource>()),
    );
    gh.factory<_i24.AuthRemoteDataSource>(
      () => _i68.AuthRemoteDataSourceImpl(gh<_i711.AuthApiService>()),
    );
    gh.factory<_i875.LookupRepository>(
      () => _i83.LookupRepositoryImpl(gh<_i633.LookupApiService>()),
    );
    gh.factory<_i948.CancelRequestUseCase>(
      () => _i948.CancelRequestUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i556.CreateRequestUseCase>(
      () => _i556.CreateRequestUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i109.GetFeaturedHandymenUseCase>(
      () => _i109.GetFeaturedHandymenUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i1043.GetHandymanDetailsUseCase>(
      () => _i1043.GetHandymanDetailsUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i650.GetHandymanPortfolioUseCase>(
      () => _i650.GetHandymanPortfolioUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i274.GetHandymenUseCase>(
      () => _i274.GetHandymenUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i476.GetProfileUseCase>(
      () => _i476.GetProfileUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i756.GetRequestsUseCase>(
      () => _i756.GetRequestsUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i1035.GetRequestDetailsUseCase>(
      () => _i1035.GetRequestDetailsUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i699.GetStatisticsUseCase>(
      () => _i699.GetStatisticsUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i488.UpdateProfileUseCase>(
      () => _i488.UpdateProfileUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i348.AddReviewUseCase>(
      () => _i348.AddReviewUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i127.GetHandymanReviewsUseCase>(
      () => _i127.GetHandymanReviewsUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i75.GetMyReviewsUseCase>(
      () => _i75.GetMyReviewsUseCase(gh<_i547.CustomerRepository>()),
    );
    gh.factory<_i787.AuthRepository>(
      () => _i409.AuthRepositoryImpl(
        gh<_i24.AuthRemoteDataSource>(),
        gh<_i64.SecureStorageService>(),
      ),
    );
    gh.factory<_i643.CustomerCubit>(
      () => _i643.CustomerCubit(
        gh<_i127.GetHandymanReviewsUseCase>(),
        gh<_i348.AddReviewUseCase>(),
        gh<_i75.GetMyReviewsUseCase>(),
        gh<_i476.GetProfileUseCase>(),
        gh<_i488.UpdateProfileUseCase>(),
        gh<_i756.GetRequestsUseCase>(),
        gh<_i556.CreateRequestUseCase>(),
        gh<_i1035.GetRequestDetailsUseCase>(),
        gh<_i948.CancelRequestUseCase>(),
        gh<_i699.GetStatisticsUseCase>(),
        gh<_i274.GetHandymenUseCase>(),
        gh<_i109.GetFeaturedHandymenUseCase>(),
        gh<_i1043.GetHandymanDetailsUseCase>(),
        gh<_i650.GetHandymanPortfolioUseCase>(),
      ),
    );
    gh.factory<_i757.NotificationRemoteDataSource>(
      () => _i655.NotificationRemoteDataSourceImpl(
        gh<_i132.NotificationApiService>(),
      ),
    );
    gh.factory<_i476.HandymanRemoteDataSource>(
      () => _i1000.HandymanRemoteDataSourceImpl(gh<_i850.HandymanApiService>()),
    );
    gh.factory<_i1068.NotificationRepository>(
      () => _i361.NotificationRepositoryImpl(
        gh<_i757.NotificationRemoteDataSource>(),
      ),
    );
    gh.factory<_i560.ForgotPasswordUseCase>(
      () => _i560.ForgotPasswordUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i1063.RegisterCustomerUseCase>(
      () => _i1063.RegisterCustomerUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i302.RegisterHandymanUseCase>(
      () => _i302.RegisterHandymanUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i474.ResetPasswordUseCase>(
      () => _i474.ResetPasswordUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i503.VerifyOtpUseCase>(
      () => _i503.VerifyOtpUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i1031.LookupCubit>(
      () => _i1031.LookupCubit(gh<_i875.LookupRepository>()),
    );
    gh.factory<_i761.HandymanRepository>(
      () => _i316.HandymanRepositoryImpl(gh<_i476.HandymanRemoteDataSource>()),
    );
    gh.factory<_i169.DeleteNotificationUseCase>(
      () =>
          _i169.DeleteNotificationUseCase(gh<_i1068.NotificationRepository>()),
    );
    gh.factory<_i587.GetNotificationsUseCase>(
      () => _i587.GetNotificationsUseCase(gh<_i1068.NotificationRepository>()),
    );
    gh.factory<_i730.MarkAllNotificationsAsReadUseCase>(
      () => _i730.MarkAllNotificationsAsReadUseCase(
        gh<_i1068.NotificationRepository>(),
      ),
    );
    gh.factory<_i889.MarkNotificationAsReadUseCase>(
      () => _i889.MarkNotificationAsReadUseCase(
        gh<_i1068.NotificationRepository>(),
      ),
    );
    gh.factory<_i335.NotificationCubit>(
      () => _i335.NotificationCubit(
        gh<_i587.GetNotificationsUseCase>(),
        gh<_i889.MarkNotificationAsReadUseCase>(),
        gh<_i730.MarkAllNotificationsAsReadUseCase>(),
        gh<_i169.DeleteNotificationUseCase>(),
      ),
    );
    gh.factory<_i117.AuthCubit>(
      () => _i117.AuthCubit(
        gh<_i188.LoginUseCase>(),
        gh<_i1063.RegisterCustomerUseCase>(),
        gh<_i302.RegisterHandymanUseCase>(),
        gh<_i560.ForgotPasswordUseCase>(),
        gh<_i474.ResetPasswordUseCase>(),
        gh<_i503.VerifyOtpUseCase>(),
      ),
    );
    gh.factory<_i373.AddPortfolioUseCase>(
      () => _i373.AddPortfolioUseCase(gh<_i761.HandymanRepository>()),
    );
    gh.factory<_i95.DeletePortfolioUseCase>(
      () => _i95.DeletePortfolioUseCase(gh<_i761.HandymanRepository>()),
    );
    gh.factory<_i8.GetAvailableRequestsUseCase>(
      () => _i8.GetAvailableRequestsUseCase(gh<_i761.HandymanRepository>()),
    );
    gh.factory<_i793.GetHandymanProfileUseCase>(
      () => _i793.GetHandymanProfileUseCase(gh<_i761.HandymanRepository>()),
    );
    gh.factory<_i920.GetHandymanStatisticsUseCase>(
      () => _i920.GetHandymanStatisticsUseCase(gh<_i761.HandymanRepository>()),
    );
    gh.factory<_i783.GetJobsUseCase>(
      () => _i783.GetJobsUseCase(gh<_i761.HandymanRepository>()),
    );
    gh.factory<_i227.GetJobDetailsUseCase>(
      () => _i227.GetJobDetailsUseCase(gh<_i761.HandymanRepository>()),
    );
    gh.factory<_i1059.GetPortfolioUseCase>(
      () => _i1059.GetPortfolioUseCase(gh<_i761.HandymanRepository>()),
    );
    gh.factory<_i718.GetReviewsUseCase>(
      () => _i718.GetReviewsUseCase(gh<_i761.HandymanRepository>()),
    );
    gh.factory<_i651.UpdateHandymanProfileUseCase>(
      () => _i651.UpdateHandymanProfileUseCase(gh<_i761.HandymanRepository>()),
    );
    gh.factory<_i651.UpdateJobStatusUseCase>(
      () => _i651.UpdateJobStatusUseCase(gh<_i761.HandymanRepository>()),
    );
    gh.factory<_i10.HandymanCubit>(
      () => _i10.HandymanCubit(
        gh<_i793.GetHandymanProfileUseCase>(),
        gh<_i651.UpdateHandymanProfileUseCase>(),
        gh<_i783.GetJobsUseCase>(),
        gh<_i227.GetJobDetailsUseCase>(),
        gh<_i651.UpdateJobStatusUseCase>(),
        gh<_i718.GetReviewsUseCase>(),
        gh<_i8.GetAvailableRequestsUseCase>(),
        gh<_i920.GetHandymanStatisticsUseCase>(),
        gh<_i1059.GetPortfolioUseCase>(),
        gh<_i373.AddPortfolioUseCase>(),
        gh<_i95.DeletePortfolioUseCase>(),
      ),
    );
    return this;
  }
}

class _$SharedPreferencesModule extends _i309.SharedPreferencesModule {}

class _$SecureStorageModule extends _i621.SecureStorageModule {}

class _$NetworkModule extends _i881.NetworkModule {}

class _$AuthServiceModule extends _i326.AuthServiceModule {}

class _$LookupModule extends _i452.LookupModule {}
