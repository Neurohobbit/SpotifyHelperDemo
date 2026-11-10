import 'package:spotify_helper/domain/models/spotify_user.dart';

abstract class AuthRepository {
  Future<SpotifyUser?> restoreSession();

  Future<SpotifyUser> login();

  Future<void> logout();
}
