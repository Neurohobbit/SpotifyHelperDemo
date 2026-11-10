import 'package:spotify_helper/core/config/app_constants.dart';
import 'package:spotify_helper/core/logging/app_logger.dart';
import 'package:spotify_helper/data/api/spotify_api_client.dart';
import 'package:spotify_helper/domain/models/spotify_playlist.dart';
import 'package:spotify_helper/domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  PlaylistRepositoryImpl({
    required SpotifyApiClient apiClient,
    required AppLogger logger,
  })  : _apiClient = apiClient,
        _logger = logger;

  final SpotifyApiClient _apiClient;
  final AppLogger _logger;

  @override
  Future<SpotifyPlaylist> findOrCreatePlaylist({
    required String name,
    required String ownerId,
  }) async {
    final existing = await _findOwnedPlaylist(name: name, ownerId: ownerId);
    if (existing != null) {
      return existing;
    }
    _logger.info('Creating Spotify playlist');
    return _apiClient.createPlaylist(name);
  }

  @override
  Future<void> replaceTracks({
    required String playlistId,
    required List<String> trackUris,
  }) async {
    await _apiClient.replacePlaylistItems(playlistId: playlistId, uris: trackUris);
    _logger.info('Replaced playlist tracks', context: {'count': trackUris.length});
  }

  /// Followed playlists with the same name belong to someone else and are
  /// read-only, so only the user's own playlist counts.
  Future<SpotifyPlaylist?> _findOwnedPlaylist({
    required String name,
    required String ownerId,
  }) async {
    for (var page = 0; page < AppConstants.maxPlaylistPages; page++) {
      final result = await _apiClient.getMyPlaylists(
        offset: page * AppConstants.playlistPageSize,
      );
      for (final playlist in result.items) {
        if (playlist.name == name && playlist.ownerId == ownerId) {
          return playlist;
        }
      }
      if (!result.hasMore) {
        break;
      }
    }
    return null;
  }
}
