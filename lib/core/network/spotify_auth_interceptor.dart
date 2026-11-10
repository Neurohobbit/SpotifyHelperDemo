import 'package:dio/dio.dart';
import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/core/logging/app_logger.dart';
import 'package:spotify_helper/data/local/token_storage.dart';
import 'package:spotify_helper/data/services/spotify_auth_service.dart';
import 'package:spotify_helper/domain/models/auth_session.dart';

class SpotifyAuthInterceptor extends QueuedInterceptor {
  SpotifyAuthInterceptor({
    required TokenStorage tokenStorage,
    required SpotifyAuthService authService,
    required AppLogger logger,
  })  : _tokenStorage = tokenStorage,
        _authService = authService,
        _logger = logger;

  final TokenStorage _tokenStorage;
  final SpotifyAuthService _authService;
  final AppLogger _logger;
  static const _retryKey = 'spotify_auth_retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final session = await _validSession();
      if (session != null) {
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      }
      handler.next(options);
    } on AppFailure catch (failure) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: failure,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final alreadyRetried = err.requestOptions.extra[_retryKey] == true;
    if (err.response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    try {
      final current = await _tokenStorage.read();
      if (current == null) {
        handler.next(err);
        return;
      }

      final refreshed = await _authService.refresh(current);
      await _tokenStorage.save(refreshed);

      final request = err.requestOptions;
      request.headers['Authorization'] = 'Bearer ${refreshed.accessToken}';
      request.extra[_retryKey] = true;
      final response = await Dio().fetch<dynamic>(request);
      handler.resolve(response);
    } catch (error) {
      _logger.warning('Spotify token refresh failed after 401');
      await _tokenStorage.clear();
      handler.next(err);
    }
  }

  Future<AuthSession?> _validSession() async {
    final session = await _tokenStorage.read();
    if (session == null) {
      return null;
    }
    if (!session.isExpiredOrExpiringSoon()) {
      return session;
    }

    try {
      final refreshed = await _authService.refresh(session);
      await _tokenStorage.save(refreshed);
      return refreshed;
    } on AppFailure {
      await _tokenStorage.clear();
      rethrow;
    }
  }
}
