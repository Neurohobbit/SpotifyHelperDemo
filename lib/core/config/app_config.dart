import 'package:spotify_helper/core/config/app_constants.dart';

class AppConfig {
  const AppConfig({
    required this.spotifyClientId,
    required this.openAiApiKey,
    this.spotifyRedirectUri = AppConstants.defaultRedirectUri,
    this.openAiModel = AppConstants.defaultOpenAiModel,
    this.targetTrackCount = AppConstants.targetTrackCount,
    this.maxReplacementRounds = AppConstants.maxReplacementRounds,
  });

  /// Values come from `.env` via `flutter run --dart-define-from-file=.env`.
  factory AppConfig.fromEnvironment() {
    return AppConfig(
      spotifyClientId: _read(const String.fromEnvironment('SPOTIFY_CLIENT_ID')),
      spotifyRedirectUri: _read(
        const String.fromEnvironment('SPOTIFY_REDIRECT_URI'),
        AppConstants.defaultRedirectUri,
      ),
      openAiApiKey: _read(const String.fromEnvironment('OPENAI_API_KEY')),
      openAiModel: _read(
        const String.fromEnvironment('OPENAI_MODEL'),
        AppConstants.defaultOpenAiModel,
      ),
    );
  }

  final String spotifyClientId;
  final String spotifyRedirectUri;
  final String openAiApiKey;
  final String openAiModel;
  final int targetTrackCount;
  final int maxReplacementRounds;

  static String _read(String value, [String fallback = '']) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
}
