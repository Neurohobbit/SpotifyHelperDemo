import 'package:spotify_helper/core/config/app_config.dart';
import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/core/logging/app_logger.dart';
import 'package:spotify_helper/domain/matching/track_resolution.dart';
import 'package:spotify_helper/domain/matching/track_text_normalizer.dart';
import 'package:spotify_helper/domain/models/music_recommendation.dart';
import 'package:spotify_helper/domain/repositories/recommendation_repository.dart';

/// Collects up to `targetTrackCount` Spotify tracks for a prompt.
///
/// 1. Ask OpenAI for songs and look them up on Spotify.
/// 2. If some were not found, ask OpenAI for replacements, telling it which
///    songs were already suggested and which ones Spotify could not find.
/// 3. Stop when the target is reached or after `maxReplacementRounds`.
///
/// Every artist appears at most once in the result.
class TrackCollector {
  TrackCollector({
    required RecommendationRepository recommendations,
    required TrackResolver resolver,
    required AppConfig config,
    required AppLogger logger,
  })  : _recommendations = recommendations,
        _resolver = resolver,
        _config = config,
        _logger = logger;

  final RecommendationRepository _recommendations;
  final TrackResolver _resolver;
  final AppConfig _config;
  final AppLogger _logger;

  Future<List<ResolvedSpotifyTrack>> collect(String userPrompt) async {
    final target = _config.targetTrackCount;
    final suggested = <String, MusicRecommendation>{};
    final found = <ResolvedSpotifyTrack>[];
    final foundSongs = <String>{};
    final usedArtists = <String>{};

    for (var round = 0; round <= _config.maxReplacementRounds; round++) {
      final missing = target - found.length;
      if (missing <= 0) {
        break;
      }

      final List<MusicRecommendation> batch;
      try {
        batch = await _recommendations.recommendTracks(
          userPrompt: userPrompt,
          count: missing,
          exclude: suggested.values.toList(),
          notFound: [
            for (final song in suggested.values)
              if (!foundSongs.contains(song.key)) song,
          ],
        );
      } on InvalidOpenAiResponseFailure {
        // A bad replacement answer should not throw away tracks already found.
        if (round == 0) {
          rethrow;
        }
        _logger.warning('Stopping replacements', context: {'round': round});
        break;
      }
      final fresh = [
        for (final song in batch)
          if (!suggested.containsKey(song.key) &&
              !usedArtists.contains(song.artistKey))
            song,
      ];
      for (final song in batch) {
        suggested.putIfAbsent(song.key, () => song);
      }
      _logger.info(
        'Collect round',
        context: {'round': round, 'missing': missing, 'fresh': fresh.length},
      );

      for (final item in await _resolver.resolve(fresh)) {
        if (found.length >= target) {
          break;
        }
        final artists = _artistKeys(item);
        if (found.any((existing) => existing.track.id == item.track.id) ||
            artists.any(usedArtists.contains)) {
          continue;
        }
        found.add(item);
        foundSongs.add(item.recommendation.key);
        usedArtists.addAll(artists);
      }
    }

    _logger.info('Collected tracks', context: {'found': found.length, 'target': target});
    return found;
  }

  /// The recommended artist plus every artist credited on Spotify, so a
  /// featured artist cannot show up again in another song.
  Set<String> _artistKeys(ResolvedSpotifyTrack item) {
    return {
      item.recommendation.artistKey,
      for (final name in item.track.artistNames)
        TrackTextNormalizer.artistKey(name),
    }..remove('');
  }
}
