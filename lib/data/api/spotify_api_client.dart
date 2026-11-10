import 'package:dio/dio.dart';
import 'package:spotify_helper/core/config/app_constants.dart';
import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/core/network/dio_error_mapper.dart';
import 'package:spotify_helper/domain/models/music_recommendation.dart';
import 'package:spotify_helper/domain/models/spotify_playlist.dart';
import 'package:spotify_helper/domain/models/spotify_track.dart';
import 'package:spotify_helper/domain/models/spotify_user.dart';

/// Thin wrapper over the Spotify Web API endpoints the app needs.
class SpotifyApiClient {
  SpotifyApiClient(this._dio);

  final Dio _dio;

  Future<SpotifyUser> getCurrentUser() {
    return _guard(() async {
      final response = await _dio.get<dynamic>('/me');
      return SpotifyUser.fromJson(_asMap(response.data));
    });
  }

  Future<SpotifyPlaylistPage> getMyPlaylists({required int offset}) {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '/me/playlists',
        queryParameters: {
          'limit': AppConstants.playlistPageSize,
          'offset': offset,
        },
      );
      final data = _asMap(response.data);
      return SpotifyPlaylistPage(
        items: _parseItems(data['items'], SpotifyPlaylist.fromJson),
        hasMore: data['next'] is String,
      );
    });
  }

  Future<SpotifyPlaylist> createPlaylist(String name) {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '/me/playlists',
        data: {'name': name, 'public': false},
      );
      return SpotifyPlaylist.fromJson(_asMap(response.data));
    });
  }

  /// One PUT replaces all items (Spotify allows up to 100 URIs).
  Future<void> replacePlaylistItems({
    required String playlistId,
    required List<String> uris,
  }) {
    return _guard(() async {
      await _dio.put<dynamic>(
        '/playlists/${Uri.encodeComponent(playlistId)}/items',
        data: {'uris': uris},
      );
    });
  }

  Future<List<SpotifyTrack>> searchTracks(MusicRecommendation recommendation) {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '/search',
        queryParameters: {
          'q': searchQuery(recommendation),
          'type': 'track',
          'limit': AppConstants.spotifySearchLimit,
          'market': 'from_token',
        },
      );
      final tracks = _asMap(response.data)['tracks'];
      return _parseItems(
        tracks is Map ? tracks['items'] : null,
        SpotifyTrack.fromJson,
      );
    });
  }

  static String searchQuery(MusicRecommendation recommendation) {
    final title = recommendation.title.replaceAll('"', ' ').trim();
    final artist = recommendation.artist.replaceAll('"', ' ').trim();
    return 'track:"$title" artist:"$artist"';
  }

  /// Parses each JSON item and silently drops the malformed ones.
  List<T> _parseItems<T>(
    dynamic rawItems,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final items = <T>[];
    if (rawItems is! List) {
      return items;
    }
    for (final item in rawItems) {
      if (item is! Map) {
        continue;
      }
      try {
        items.add(fromJson(Map<String, dynamic>.from(item)));
      } on FormatException {
        continue;
      }
    }
    return items;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is! Map) {
      throw const FormatException('Expected a JSON object');
    }
    return Map<String, dynamic>.from(data);
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on FormatException {
      throw const SpotifyFailure();
    } on DioException catch (error) {
      throw mapSpotifyDioException(error);
    }
  }
}
