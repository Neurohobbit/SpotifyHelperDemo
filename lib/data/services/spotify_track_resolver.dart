import 'package:spotify_helper/core/config/app_constants.dart';
import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/core/logging/app_logger.dart';
import 'package:spotify_helper/core/utils/async_pool.dart';
import 'package:spotify_helper/data/api/spotify_api_client.dart';
import 'package:spotify_helper/domain/matching/spotify_track_matcher.dart';
import 'package:spotify_helper/domain/matching/track_resolution.dart';
import 'package:spotify_helper/domain/models/music_recommendation.dart';

/// Searches Spotify for each recommendation, a few requests at a time.
class SpotifyTrackResolver implements TrackResolver {
  SpotifyTrackResolver({
    required SpotifyApiClient apiClient,
    required AppLogger logger,
    this.concurrency = AppConstants.searchConcurrency,
    SpotifyTrackMatcher matcher = const SpotifyTrackMatcher(),
  })  : _apiClient = apiClient,
        _logger = logger,
        _matcher = matcher;

  final SpotifyApiClient _apiClient;
  final AppLogger _logger;
  final SpotifyTrackMatcher _matcher;
  final int concurrency;

  @override
  Future<List<ResolvedSpotifyTrack>> resolve(
    List<MusicRecommendation> recommendations,
  ) async {
    final results = await mapPool(
      items: recommendations,
      concurrency: concurrency,
      mapper: _resolveOne,
    );
    return [for (final result in results) ?result];
  }

  Future<ResolvedSpotifyTrack?> _resolveOne(
    MusicRecommendation recommendation,
  ) async {
    try {
      final candidates = await _apiClient.searchTracks(recommendation);
      final track = _matcher.match(
        recommendation: recommendation,
        candidates: candidates,
      );
      if (track != null) {
        return ResolvedSpotifyTrack(recommendation: recommendation, track: track);
      }
    } on AppFailure {
      // A failed search counts as "not found" instead of failing the batch.
    }
    _logger.info(
      'Not on Spotify: ${recommendation.title} — ${recommendation.artist}',
    );
    return null;
  }
}
