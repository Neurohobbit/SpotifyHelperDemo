class SpotifyUser {
  const SpotifyUser({
    required this.id,
    required this.displayName,
  });

  final String id;
  final String displayName;

  factory SpotifyUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Missing Spotify user id');
    }

    final rawName = json['display_name'];
    final displayName = rawName is String && rawName.trim().isNotEmpty
        ? rawName.trim()
        : id;

    return SpotifyUser(id: id, displayName: displayName);
  }
}
