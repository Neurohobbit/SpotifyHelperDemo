import 'package:spotify_helper/domain/matching/track_text_normalizer.dart';

/// A song suggested by OpenAI, before it is matched to a Spotify track.
class MusicRecommendation {
  const MusicRecommendation({required this.title, required this.artist});

  final String title;
  final String artist;

  /// Same song regardless of case, punctuation or "Remastered" suffixes.
  String get key => '${TrackTextNormalizer.normalize(title)}|$artistKey';

  String get artistKey => TrackTextNormalizer.artistKey(artist);

  @override
  bool operator ==(Object other) {
    return other is MusicRecommendation &&
        other.title == title &&
        other.artist == artist;
  }

  @override
  int get hashCode => Object.hash(title, artist);
}
