abstract final class AppConstants {
  static const myVibePlaylistName = 'My Vibe';
  static const targetTrackCount = 30;
  static const maxReplacementRounds = 3;
  static const openAiAttempts = 3;
  static const defaultOpenAiModel = 'gpt-4o-mini';

  static const spotifySearchLimit = 5;
  static const searchConcurrency = 4;
  static const playlistPageSize = 50;
  static const maxPlaylistPages = 20;

  static const spotifyApiBaseUrl = 'https://api.spotify.com/v1';
  static const spotifyAccountsBaseUrl = 'https://accounts.spotify.com';
  static const openAiApiBaseUrl = 'https://api.openai.com/v1';

  static const defaultRedirectUri = 'spotifyhelper://auth/callback';

  static const spotifyScopes = [
    'playlist-read-private',
    'playlist-modify-public',
    'playlist-modify-private',
    'user-read-private',
  ];
}
