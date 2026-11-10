import 'package:spotify_helper/core/config/app_constants.dart';
import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/data/services/track_collector.dart';
import 'package:spotify_helper/domain/models/spotify_track.dart';
import 'package:spotify_helper/domain/repositories/playlist_repository.dart';
import 'package:spotify_helper/features/playlist_generation/application/playlist_generation_state.dart';

/// Prompt → Spotify tracks → saved into the user's "My Vibe" playlist.
class GeneratePlaylistUseCase {
  GeneratePlaylistUseCase({
    required TrackCollector collector,
    required PlaylistRepository playlists,
  })  : _collector = collector,
        _playlists = playlists;

  final TrackCollector _collector;
  final PlaylistRepository _playlists;

  Future<List<SpotifyTrack>> execute({
    required String userPrompt,
    required String ownerId,
    void Function(GenerationStatus status)? onProgress,
  }) async {
    final prompt = userPrompt.trim();
    if (prompt.isEmpty) {
      throw const ValidationFailure();
    }

    onProgress?.call(GenerationStatus.findingTracks);
    final found = await _collector.collect(prompt);
    if (found.isEmpty) {
      throw const NoTracksFoundFailure();
    }
    final tracks = [for (final item in found) item.track];

    // My Vibe is touched only after the tracks are known, so a failed
    // search never leaves the user with an emptied playlist.
    onProgress?.call(GenerationStatus.savingPlaylist);
    final playlist = await _playlists.findOrCreatePlaylist(
      name: AppConstants.myVibePlaylistName,
      ownerId: ownerId,
    );
    await _playlists.replaceTracks(
      playlistId: playlist.id,
      trackUris: [for (final track in tracks) track.uri],
    );
    return tracks;
  }
}
