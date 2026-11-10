import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_helper/core/config/app_config.dart';
import 'package:spotify_helper/core/config/app_constants.dart';
import 'package:spotify_helper/core/logging/app_logger.dart';
import 'package:spotify_helper/core/network/dio_factory.dart';
import 'package:spotify_helper/core/network/openai_auth_interceptor.dart';
import 'package:spotify_helper/core/network/spotify_auth_interceptor.dart';
import 'package:spotify_helper/data/api/openai_api_client.dart';
import 'package:spotify_helper/data/api/spotify_api_client.dart';
import 'package:spotify_helper/data/local/secure_token_storage.dart';
import 'package:spotify_helper/data/local/token_storage.dart';
import 'package:spotify_helper/data/repositories/auth_repository_impl.dart';
import 'package:spotify_helper/data/repositories/openai_recommendation_repository.dart';
import 'package:spotify_helper/data/repositories/playlist_repository_impl.dart';
import 'package:spotify_helper/data/services/auth_browser.dart';
import 'package:spotify_helper/data/services/flutter_web_auth_browser.dart';
import 'package:spotify_helper/data/services/spotify_auth_service.dart';
import 'package:spotify_helper/data/services/spotify_track_resolver.dart';
import 'package:spotify_helper/data/services/track_collector.dart';
import 'package:spotify_helper/domain/matching/track_resolution.dart';
import 'package:spotify_helper/domain/repositories/auth_repository.dart';
import 'package:spotify_helper/domain/repositories/playlist_repository.dart';
import 'package:spotify_helper/domain/repositories/recommendation_repository.dart';
import 'package:spotify_helper/features/playlist_generation/application/generate_playlist_use_case.dart';

// Core

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

final appLoggerProvider = Provider<AppLogger>((ref) => AppLogger());

final dioFactoryProvider = Provider<DioFactory>((ref) {
  return DioFactory(ref.watch(appLoggerProvider));
});

final tokenStorageProvider = Provider<TokenStorage>((ref) => SecureTokenStorage());

final authBrowserProvider = Provider<AuthBrowser>((ref) => const FlutterWebAuthBrowser());

// Spotify

final spotifyAuthServiceProvider = Provider<SpotifyAuthService>((ref) {
  return SpotifyAuthService(
    config: ref.watch(appConfigProvider),
    accountsDio: ref.watch(dioFactoryProvider).create(
          baseUrl: AppConstants.spotifyAccountsBaseUrl,
        ),
    browser: ref.watch(authBrowserProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final spotifyApiClientProvider = Provider<SpotifyApiClient>((ref) {
  final Dio dio = ref.watch(dioFactoryProvider).create(
    baseUrl: AppConstants.spotifyApiBaseUrl,
    extraInterceptors: [
      SpotifyAuthInterceptor(
        tokenStorage: ref.watch(tokenStorageProvider),
        authService: ref.watch(spotifyAuthServiceProvider),
        logger: ref.watch(appLoggerProvider),
      ),
    ],
  );
  return SpotifyApiClient(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    tokenStorage: ref.watch(tokenStorageProvider),
    authService: ref.watch(spotifyAuthServiceProvider),
    apiClient: ref.watch(spotifyApiClientProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepositoryImpl(
    apiClient: ref.watch(spotifyApiClientProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final trackResolverProvider = Provider<TrackResolver>((ref) {
  return SpotifyTrackResolver(
    apiClient: ref.watch(spotifyApiClientProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

// OpenAI

final openAiApiClientProvider = Provider<OpenAiApiClient>((ref) {
  final Dio dio = ref.watch(dioFactoryProvider).create(
    baseUrl: AppConstants.openAiApiBaseUrl,
    receiveTimeout: const Duration(seconds: 60),
    extraInterceptors: [
      OpenAiAuthInterceptor(ref.watch(appConfigProvider).openAiApiKey),
    ],
  );
  return OpenAiApiClient(dio);
});

final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  return OpenAiRecommendationRepository(
    config: ref.watch(appConfigProvider),
    apiClient: ref.watch(openAiApiClientProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

// Playlist generation

final trackCollectorProvider = Provider<TrackCollector>((ref) {
  return TrackCollector(
    recommendations: ref.watch(recommendationRepositoryProvider),
    resolver: ref.watch(trackResolverProvider),
    config: ref.watch(appConfigProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final generatePlaylistUseCaseProvider = Provider<GeneratePlaylistUseCase>((ref) {
  return GeneratePlaylistUseCase(
    collector: ref.watch(trackCollectorProvider),
    playlists: ref.watch(playlistRepositoryProvider),
  );
});
