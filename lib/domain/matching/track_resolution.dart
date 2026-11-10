import 'package:spotify_helper/domain/models/music_recommendation.dart';
import 'package:spotify_helper/domain/models/spotify_track.dart';

class ResolvedSpotifyTrack {
  const ResolvedSpotifyTrack({
    required this.recommendation,
    required this.track,
  });

  final MusicRecommendation recommendation;
  final SpotifyTrack track;
}

/// Finds Spotify tracks for recommendations. Songs that are not found are
/// simply left out of the result.
abstract class TrackResolver {
  Future<List<ResolvedSpotifyTrack>> resolve(
    List<MusicRecommendation> recommendations,
  );
}
