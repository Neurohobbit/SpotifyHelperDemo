import 'package:dio/dio.dart';
import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/core/network/dio_error_mapper.dart';

class OpenAiApiClient {
  OpenAiApiClient(this._dio);

  final Dio _dio;

  /// Returns the assistant message text from a Chat Completions call.
  Future<String> createChatCompletion({
    required String model,
    required List<Map<String, String>> messages,
    required Map<String, dynamic> responseFormat,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        '/chat/completions',
        data: {
          'model': model,
          'messages': messages,
          'response_format': responseFormat,
        },
      );
    } on DioException catch (error) {
      throw mapOpenAiDioException(error);
    }

    final data = response.data;
    final choices = data is Map ? data['choices'] : null;
    final first = choices is List && choices.isNotEmpty ? choices.first : null;
    final message = first is Map ? first['message'] : null;
    final content = message is Map ? message['content'] : null;
    if (content is String && content.trim().isNotEmpty) {
      return content;
    }
    throw const InvalidOpenAiResponseFailure();
  }
}
