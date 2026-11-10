import 'package:spotify_helper/domain/models/music_recommendation.dart';

/// Prompt text and JSON schema sent to OpenAI.
abstract final class OpenAiPrompts {
  static String system({required int count}) {
    return '''
You are a music recommendation engine.
Recommend up to $count real songs matching the user's request.
Rules:
- Only recommend songs and artists you are certain actually exist and are available on Spotify.
- Never invent, guess, or transliterate fake band names or song titles.
- If you cannot fill $count real songs, return fewer. A shorter real list is required. Do not pad.
- Each song must be by a different artist. Do not repeat artists.
- Prefer well-known official releases over obscure titles you are unsure about.
- For regional or niche scenes, only include songs you can specifically recall as real releases.
- Use official Latin or commonly catalogued names that Spotify search can find.
- Each item must contain "title" and "artist" only.
''';
  }

  static String user({
    required String userPrompt,
    required int count,
    required List<MusicRecommendation> exclude,
    required List<MusicRecommendation> notFound,
  }) {
    final buffer = StringBuffer()
      ..writeln('Recommend up to $count real songs matching this request:')
      ..writeln(userPrompt)
      ..writeln()
      ..writeln('Return fewer than $count if you run out. Never invent tracks.');
    if (exclude.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Do not include these tracks or artists:')
        ..writeln(_list(exclude));
    }
    if (notFound.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(
          'Spotify could not find these songs. They may not exist. '
          'Suggest different real songs instead:',
        )
        ..writeln(_list(notFound));
    }
    return buffer.toString();
  }

  static Map<String, dynamic> responseFormat({required int count}) {
    return {
      'type': 'json_schema',
      'json_schema': {
        'name': 'playlist_recommendations',
        'strict': true,
        'schema': {
          'type': 'object',
          'properties': {
            'tracks': {
              'type': 'array',
              'minItems': 1,
              'maxItems': count,
              'items': {
                'type': 'object',
                'properties': {
                  'title': {'type': 'string'},
                  'artist': {'type': 'string'},
                },
                'required': ['title', 'artist'],
                'additionalProperties': false,
              },
            },
          },
          'required': ['tracks'],
          'additionalProperties': false,
        },
      },
    };
  }

  static String _list(List<MusicRecommendation> tracks) {
    return tracks.map((track) => '- ${track.title} by ${track.artist}').join('\n');
  }
}
