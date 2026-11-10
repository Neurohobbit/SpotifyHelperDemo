import 'package:spotify_helper/domain/models/spotify_playlist.dart';

abstract class PlaylistRepository {
  /// Returns the user's own playlist with [name], creating it if needed.
  Future<SpotifyPlaylist> findOrCreatePlaylist({
    required String name,
    required String ownerId,
  });

  /// Overwrites everything in the playlist with [trackUris].
  Future<void> replaceTracks({
    required String playlistId,
    required List<String> trackUris,
  });
}
