import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/domain/models/spotify_track.dart';

enum GenerationStatus { idle, findingTracks, savingPlaylist, done, error }

class PlaylistGenerationState {
  const PlaylistGenerationState({
    this.status = GenerationStatus.idle,
    this.tracks = const [],
    this.failure,
  });

  final GenerationStatus status;
  final List<SpotifyTrack> tracks;
  final AppFailure? failure;

  bool get isBusy =>
      status == GenerationStatus.findingTracks ||
      status == GenerationStatus.savingPlaylist;
}
