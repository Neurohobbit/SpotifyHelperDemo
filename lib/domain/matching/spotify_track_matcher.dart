import 'package:spotify_helper/domain/matching/track_text_normalizer.dart';
import 'package:spotify_helper/domain/models/music_recommendation.dart';
import 'package:spotify_helper/domain/models/spotify_track.dart';

/// Picks the Spotify search result that is really the recommended song.
///
/// Only exact title + artist matches count, so invented songs never slip in.
class SpotifyTrackMatcher {
  const SpotifyTrackMatcher();

  SpotifyTrack? match({
    required MusicRecommendation recommendation,
    required List<SpotifyTrack> candidates,
  }) {
    final matches = [
      for (final candidate in candidates)
        if (TrackTextNormalizer.sameTitle(recommendation.title, candidate.name) &&
            candidate.artistNames.any(
              (name) =>
                  TrackTextNormalizer.artistKey(name) ==
                  recommendation.artistKey,
            ))
          candidate,
    ];
    if (matches.isEmpty) {
      return null;
    }
    final wantedTitle = TrackTextNormalizer.normalize(recommendation.title);
    return matches.firstWhere(
      (track) => TrackTextNormalizer.normalize(track.name) == wantedTitle,
      orElse: () => matches.first,
    );
  }
}
