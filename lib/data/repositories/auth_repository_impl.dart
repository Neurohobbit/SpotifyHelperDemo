import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/core/logging/app_logger.dart';
import 'package:spotify_helper/data/api/spotify_api_client.dart';
import 'package:spotify_helper/data/local/token_storage.dart';
import 'package:spotify_helper/data/services/spotify_auth_service.dart';
import 'package:spotify_helper/domain/models/spotify_user.dart';
import 'package:spotify_helper/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required TokenStorage tokenStorage,
    required SpotifyAuthService authService,
    required SpotifyApiClient apiClient,
    required AppLogger logger,
  })  : _tokenStorage = tokenStorage,
        _authService = authService,
        _apiClient = apiClient,
        _logger = logger;

  final TokenStorage _tokenStorage;
  final SpotifyAuthService _authService;
  final SpotifyApiClient _apiClient;
  final AppLogger _logger;

  @override
  Future<SpotifyUser?> restoreSession() async {
    final session = await _tokenStorage.read();
    if (session == null) {
      return null;
    }

    try {
      if (session.isExpiredOrExpiringSoon()) {
        final refreshed = await _authService.refresh(session);
        await _tokenStorage.save(refreshed);
      }
      final user = await _apiClient.getCurrentUser();
      _logger.info('Spotify session restored');
      return user;
    } on AuthFailure {
      await _tokenStorage.clear();
      rethrow;
    }
  }

  @override
  Future<SpotifyUser> login() async {
    final session = await _authService.login();
    await _tokenStorage.save(session);
    try {
      final user = await _apiClient.getCurrentUser();
      _logger.info('Spotify user profile loaded');
      return user;
    } catch (error) {
      await _tokenStorage.clear();
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
    _logger.info('Spotify session cleared');
  }
}
