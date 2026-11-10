sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;
}

final class AuthFailure extends AppFailure {
  const AuthFailure([
    super.message = 'Spotify authentication failed. Please sign in again.',
  ]);
}

final class AuthCancelledFailure extends AppFailure {
  const AuthCancelledFailure() : super('Authentication cancelled.');
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'Network request failed. Please try again.',
  ]);
}

final class SpotifyFailure extends AppFailure {
  const SpotifyFailure([
    super.message = 'Spotify is temporarily unavailable. Please try again.',
  ]);
}

final class OpenAiFailure extends AppFailure {
  const OpenAiFailure([
    super.message =
        'Could not generate playlist recommendations. Please try again.',
  ]);
}

/// OpenAI answered, but not with a usable track list. Worth retrying.
final class InvalidOpenAiResponseFailure extends OpenAiFailure {
  const InvalidOpenAiResponseFailure();
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure([
    super.message = 'Please describe the playlist you want to create.',
  ]);
}

final class NoTracksFoundFailure extends AppFailure {
  const NoTracksFoundFailure([
    super.message = 'Spotify could not find any of the recommended tracks.',
  ]);
}
