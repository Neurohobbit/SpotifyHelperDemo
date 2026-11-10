class SpotifyPlaylist {
  const SpotifyPlaylist({
    required this.id,
    required this.name,
    required this.ownerId,
  });

  final String id;
  final String name;
  final String ownerId;

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final owner = json['owner'];
    final ownerId = owner is Map ? owner['id'] : null;
    if (id is! String || name is! String || ownerId is! String) {
      throw const FormatException('Invalid Spotify playlist');
    }
    return SpotifyPlaylist(id: id, name: name, ownerId: ownerId);
  }
}

class SpotifyPlaylistPage {
  const SpotifyPlaylistPage({required this.items, required this.hasMore});

  final List<SpotifyPlaylist> items;
  final bool hasMore;
}
