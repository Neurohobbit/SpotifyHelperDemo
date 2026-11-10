class SpotifyTrack {
  const SpotifyTrack({
    required this.id,
    required this.uri,
    required this.name,
    required this.artistNames,
  });

  final String id;
  final String uri;
  final String name;
  final List<String> artistNames;

  String get artistLabel => artistNames.join(', ');

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final uri = json['uri'];
    final rawArtists = json['artists'];
    final artists = [
      if (rawArtists is List)
        for (final artist in rawArtists)
          if (artist is Map && artist['name'] is String) artist['name'] as String,
    ];
    if (id is! String || name is! String || artists.isEmpty) {
      throw const FormatException('Invalid Spotify track');
    }
    return SpotifyTrack(
      id: id,
      uri: uri is String ? uri : 'spotify:track:$id',
      name: name,
      artistNames: artists,
    );
  }
}
