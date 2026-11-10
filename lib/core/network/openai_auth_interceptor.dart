import 'package:dio/dio.dart';

class OpenAiAuthInterceptor extends Interceptor {
  OpenAiAuthInterceptor(this._apiKey);

  final String _apiKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_apiKey.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_apiKey';
    }
    handler.next(options);
  }
}
