// import 'package:dio/dio.dart';
// import 'package:injectable/injectable.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// import '../../constants/values/api_endpoints.dart';
//
// @module
// abstract class DioModule {
//
//   @lazySingleton
//   Dio provideDio() {
//     Dio dio = Dio();
//     dio.options.headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       'Authorization': 'Bearer ${ApiEndpoints.token}',
//
//     };
//     dio.options.baseUrl = ApiEndpoints.baseUrl;
//     dio.interceptors.add(dioLogger);
//     return dio;
//   }
//
//   @lazySingleton
//   PrettyDioLogger get dioLogger => PrettyDioLogger(
//     request: true,
//     requestHeader: true,
//     requestBody: true,
//     responseBody: true,
//     responseHeader: false,
//   );
// }