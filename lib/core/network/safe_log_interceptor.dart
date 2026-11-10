import 'package:dio/dio.dart';
import 'package:spotify_helper/core/logging/app_logger.dart';

class SafeLogInterceptor extends Interceptor {
  SafeLogInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.info('HTTP ${options.method} ${_path(options.uri)}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final request = response.requestOptions;
    _logger.info(
      'HTTP ${response.statusCode} ${request.method} ${_path(request.uri)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    _logger.warning(
      'HTTP ${err.response?.statusCode ?? '-'} ${request.method} ${_path(request.uri)}',
    );
    handler.next(err);
  }

  String _path(Uri uri) => uri.path.isEmpty ? '/' : uri.path;
}
