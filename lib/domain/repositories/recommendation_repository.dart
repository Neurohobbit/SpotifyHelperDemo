import 'package:spotify_helper/domain/models/music_recommendation.dart';

abstract class RecommendationRepository {
  /// Asks for up to [count] songs for [userPrompt].
  ///
  /// [exclude] were already suggested; [notFound] were suggested but are not
  /// on Spotify, so the model should stop inventing similar names.
  Future<List<MusicRecommendation>> recommendTracks({
    required String userPrompt,
    required int count,
    List<MusicRecommendation> exclude = const [],
    List<MusicRecommendation> notFound = const [],
  });
}
