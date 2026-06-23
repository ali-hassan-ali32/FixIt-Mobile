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
import '../../features/customer/domain/usecases/cancel_request_usecase.dart'
    as _i948;
import '../../features/customer/domain/usecases/create_request_usecase.dart'
    as _i556;
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
import '../../features/lookups/api/services/lookup_api_service.dart' as _i633;
import '../../features/lookups/data/repository/lookup_repository_impl.dart'
    as _i83;
import '../../features/lookups/domain/repositories/lookup_repository.dart'
    as _i875;
import '../../features/lookups/presentation/cubit/lookup_cubit.dart' as _i1031;
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
    gh.factory<_i787.AuthRepository>(
      () => _i409.AuthRepositoryImpl(
        gh<_i24.AuthRemoteDataSource>(),
        gh<_i64.SecureStorageService>(),
      ),
    );
    gh.factory<_i643.CustomerCubit>(
      () => _i643.CustomerCubit(
        gh<_i476.GetProfileUseCase>(),
        gh<_i488.UpdateProfileUseCase>(),
        gh<_i756.GetRequestsUseCase>(),
        gh<_i556.CreateRequestUseCase>(),
        gh<_i1035.GetRequestDetailsUseCase>(),
        gh<_i948.CancelRequestUseCase>(),
        gh<_i699.GetStatisticsUseCase>(),
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
    return this;
  }
}

class _$SharedPreferencesModule extends _i309.SharedPreferencesModule {}

class _$SecureStorageModule extends _i621.SecureStorageModule {}

class _$NetworkModule extends _i881.NetworkModule {}

class _$AuthServiceModule extends _i326.AuthServiceModule {}

class _$LookupModule extends _i452.LookupModule {}
