import 'package:dio/dio.dart';
import 'dio_error_handler.dart';

sealed class ApiResult<T> {}

class ApiSuccessResult<T> extends ApiResult<T> {
  T data;
  ApiSuccessResult(this.data);
}

class ApiErrorResult<T> extends ApiResult<T> {
  Object error;
  late String errorMessage;
  ApiErrorResult(this.error) {
    if (error is DioException) {
      errorMessage = handleDioError(error as DioException);
    } else {
      errorMessage = error.toString();
    }
  }
}

Future<ApiResult<TOut>> safeApiCall<TIn, TOut>(
  Future<TIn> Function() apiCall,
  TOut Function(TIn) transform,
) async {
  try {
    final result = await apiCall();
    return ApiSuccessResult(transform(result));
  } catch (e) {
    return ApiErrorResult(e);
  }
}

