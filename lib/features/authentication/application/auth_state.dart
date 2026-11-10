import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/domain/models/spotify_user.dart';

enum AuthStatus { restoring, unauthenticated, authenticating, authenticated }

class AuthState {
  const AuthState({required this.status, this.user, this.failure});

  final AuthStatus status;
  final SpotifyUser? user;
  final AppFailure? failure;
}
