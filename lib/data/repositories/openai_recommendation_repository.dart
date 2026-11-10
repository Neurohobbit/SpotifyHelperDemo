import 'package:spotify_helper/core/config/app_config.dart';
import 'package:spotify_helper/core/config/app_constants.dart';
import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/core/logging/app_logger.dart';
import 'package:spotify_helper/data/api/openai_api_client.dart';
import 'package:spotify_helper/data/services/openai_prompts.dart';
import 'package:spotify_helper/domain/models/music_recommendation.dart';
import 'package:spotify_helper/domain/openai/openai_recommendation_parser.dart';
import 'package:spotify_helper/domain/repositories/recommendation_repository.dart';

class OpenAiRecommendationRepository implements RecommendationRepository {
  OpenAiRecommendationRepository({
    required AppConfig config,
    required OpenAiApiClient apiClient,
    required AppLogger logger,
    OpenAiRecommendationParser parser = const OpenAiRecommendationParser(),
  })  : _config = config,
        _apiClient = apiClient,
        _logger = logger,
        _parser = parser;

  final AppConfig _config;
  final OpenAiApiClient _apiClient;
  final AppLogger _logger;
  final OpenAiRecommendationParser _parser;

  @override
  Future<List<MusicRecommendation>> recommendTracks({
    required String userPrompt,
    required int count,
    List<MusicRecommendation> exclude = const [],
    List<MusicRecommendation> notFound = const [],
  }) async {
    if (_config.openAiApiKey.isEmpty) {
      throw const OpenAiFailure('OpenAI is not configured.');
    }

    final messages = [
      {'role': 'system', 'content': OpenAiPrompts.system(count: count)},
      {
        'role': 'user',
        'content': OpenAiPrompts.user(
          userPrompt: userPrompt,
          count: count,
          exclude: exclude,
          notFound: notFound,
        ),
      },
    ];

    // Only a malformed answer is retried; HTTP errors fail right away.
    for (var attempt = 1; ; attempt++) {
      try {
        final content = await _apiClient.createChatCompletion(
          model: _config.openAiModel,
          messages: messages,
          responseFormat: OpenAiPrompts.responseFormat(count: count),
        );
        final tracks = _parser.parse(content, maxCount: count);
        for (final track in tracks) {
          _logger.info('OpenAI: ${track.title} — ${track.artist}');
        }
        return tracks;
      } on InvalidOpenAiResponseFailure {
        _logger.warning('OpenAI answer was invalid', context: {'attempt': attempt});
        if (attempt >= AppConstants.openAiAttempts) {
          rethrow;
        }
      }
    }
  }
}
