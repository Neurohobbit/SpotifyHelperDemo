import 'package:dio/dio.dart';
import 'package:spotify_helper/core/errors/app_failure.dart';

AppFailure mapSpotifyDioException(DioException error) {
  final wrapped = error.error;
  if (wrapped is AppFailure) {
    return wrapped;
  }
  if (error.type == DioExceptionType.cancel) {
    return const AuthCancelledFailure();
  }
  if (error.type != DioExceptionType.badResponse) {
    return const NetworkFailure();
  }
  final status = error.response?.statusCode;
  if (status == 401 || status == 403) {
    return const AuthFailure();
  }
  return const SpotifyFailure();
}

AppFailure mapOpenAiDioException(DioException error) {
  if (error.type != DioExceptionType.badResponse) {
    return const NetworkFailure();
  }
  switch (error.response?.statusCode) {
    case 401:
      return const OpenAiFailure(
        'OpenAI rejected the API key. Check the key and try again.',
      );
    case 429:
      if ('${error.response?.data}'.contains('quota')) {
        return const OpenAiFailure(
          'OpenAI quota exceeded. Add billing credit and try again.',
        );
      }
      return const OpenAiFailure(
        'OpenAI is rate limited. Wait a moment and try again.',
      );
    default:
      return const OpenAiFailure();
  }
}
