import 'package:spotify_helper/core/config/app_constants.dart';

abstract final class SpotifyAuthorizeUrl {
  static Uri build({
    required String clientId,
    required String redirectUri,
    required String codeChallenge,
    required String state,
    List<String> scopes = AppConstants.spotifyScopes,
  }) {
    return Uri.parse('${AppConstants.spotifyAccountsBaseUrl}/authorize').replace(
      queryParameters: {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'code_challenge_method': 'S256',
        'code_challenge': codeChallenge,
        'state': state,
        'scope': scopes.join(' '),
      },
    );
  }
}
