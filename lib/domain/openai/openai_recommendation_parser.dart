import 'dart:convert';

import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/domain/models/music_recommendation.dart';

/// Reads OpenAI's `{"tracks": [{"title", "artist"}]}` answer.
///
/// Malformed items and repeated songs or artists are dropped; the answer
/// only fails when it is not JSON or nothing usable is left.
class OpenAiRecommendationParser {
  const OpenAiRecommendationParser();

  List<MusicRecommendation> parse(dynamic input, {required int maxCount}) {
    final rawTracks = _decode(input)['tracks'];
    if (rawTracks is! List) {
      throw const InvalidOpenAiResponseFailure();
    }

    final tracks = <MusicRecommendation>[];
    final seenArtists = <String>{};
    for (final item in rawTracks) {
      final track = _track(item);
      if (track != null && seenArtists.add(track.artistKey)) {
        tracks.add(track);
      }
      if (tracks.length == maxCount) {
        break;
      }
    }
    if (tracks.isEmpty) {
      throw const InvalidOpenAiResponseFailure();
    }
    return tracks;
  }

  Map<dynamic, dynamic> _decode(dynamic input) {
    try {
      final decoded = input is String ? jsonDecode(_stripFences(input)) : input;
      if (decoded is Map) {
        return decoded;
      }
    } on FormatException {
      // Falls through to the failure below.
    }
    throw const InvalidOpenAiResponseFailure();
  }

  MusicRecommendation? _track(dynamic item) {
    final title = item is Map ? item['title'] : null;
    final artist = item is Map ? item['artist'] : null;
    if (title is! String || artist is! String) {
      return null;
    }
    final track = MusicRecommendation(title: title.trim(), artist: artist.trim());
    if (track.title.isEmpty || track.artistKey.isEmpty) {
      return null;
    }
    return track;
  }

  String _stripFences(String raw) {
    return raw
        .trim()
        .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\s*```$'), '');
  }
}
