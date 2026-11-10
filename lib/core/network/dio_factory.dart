import 'package:dio/dio.dart';
import 'package:spotify_helper/core/logging/app_logger.dart';
import 'package:spotify_helper/core/network/safe_log_interceptor.dart';

class DioFactory {
  const DioFactory(this._logger);

  final AppLogger _logger;

  Dio create({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 20),
    Duration receiveTimeout = const Duration(seconds: 20),
    List<Interceptor> extraInterceptors = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: const {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.addAll([
      SafeLogInterceptor(_logger),
      ...extraInterceptors,
    ]);
    return dio;
  }
}
