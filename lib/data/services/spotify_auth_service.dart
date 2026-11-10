import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:spotify_helper/core/config/app_config.dart';
import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/core/logging/app_logger.dart';
import 'package:spotify_helper/core/network/dio_error_mapper.dart';
import 'package:spotify_helper/core/utils/pkce.dart';
import 'package:spotify_helper/data/services/auth_browser.dart';
import 'package:spotify_helper/data/services/spotify_authorize_url.dart';
import 'package:spotify_helper/domain/models/auth_session.dart';

class SpotifyAuthService {
  SpotifyAuthService({
    required AppConfig config,
    required Dio accountsDio,
    required AuthBrowser browser,
    required AppLogger logger,
  })  : _config = config,
        _accountsDio = accountsDio,
        _browser = browser,
        _logger = logger;

  final AppConfig _config;
  final Dio _accountsDio;
  final AuthBrowser _browser;
  final AppLogger _logger;

  Future<AuthSession> login() async {
    if (_config.spotifyClientId.isEmpty) {
      throw const AuthFailure(
        'Spotify Client ID is missing. Add it to .env.',
      );
    }

    final verifier = Pkce.verifier();
    final state = Pkce.verifier();
    final redirectUri = _config.spotifyRedirectUri;
    final authorizationUrl = SpotifyAuthorizeUrl.build(
      clientId: _config.spotifyClientId,
      redirectUri: redirectUri,
      codeChallenge: Pkce.challenge(verifier),
      state: state,
    );

    _logger.info('Spotify OAuth started');

    final callback = await _openBrowser(
      authorizationUrl: authorizationUrl,
      callbackUrlScheme: Uri.parse(redirectUri).scheme,
    );

    final error = callback.queryParameters['error'];
    if (error != null && error.isNotEmpty) {
      throw const AuthFailure();
    }

    final returnedState = callback.queryParameters['state'];
    if (returnedState != state) {
      throw const AuthFailure();
    }

    final code = callback.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw const AuthFailure();
    }

    final session = await _exchangeToken({
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri,
      'client_id': _config.spotifyClientId,
      'code_verifier': verifier,
    });
    _logger.info('Spotify token exchange succeeded');
    return session;
  }

  Future<AuthSession> refresh(AuthSession session) async {
    _logger.info('Spotify token refresh started');
    final refreshed = await _exchangeToken(
      {
        'grant_type': 'refresh_token',
        'refresh_token': session.refreshToken,
        'client_id': _config.spotifyClientId,
      },
      previous: session,
    );
    _logger.info('Spotify token refresh succeeded');
    return refreshed;
  }

  Future<Uri> _openBrowser({
    required Uri authorizationUrl,
    required String callbackUrlScheme,
  }) async {
    try {
      return await _browser.authenticate(
        authorizationUrl: authorizationUrl,
        callbackUrlScheme: callbackUrlScheme,
      );
    } on AuthCancelledFailure {
      rethrow;
    } on AppFailure {
      rethrow;
    } on PlatformException catch (error) {
      if (_isCancelled(error.code)) {
        throw const AuthCancelledFailure();
      }
      throw const AuthFailure();
    } catch (_) {
      throw const AuthFailure();
    }
  }

  Future<AuthSession> _exchangeToken(
    Map<String, String> body, {
    AuthSession? previous,
  }) async {
    try {
      final response = await _accountsDio.post<dynamic>(
        '/api/token',
        data: body,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final data = response.data;
      if (data is! Map) {
        throw const AuthFailure();
      }
      return AuthSession.fromTokenResponse(
        Map<String, dynamic>.from(data),
        previous: previous,
      );
    } on AppFailure {
      rethrow;
    } on FormatException {
      throw const AuthFailure();
    } on DioException catch (error) {
      throw mapSpotifyDioException(error);
    }
  }

  bool _isCancelled(String code) {
    final normalized = code.toLowerCase();
    return normalized == 'canceled' || normalized == 'cancelled';
  }
}
