import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_helper/core/di/providers.dart';
import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/domain/models/spotify_user.dart';
import 'package:spotify_helper/features/authentication/application/auth_state.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    unawaited(_signIn(ref.read(authRepositoryProvider).restoreSession));
    return const AuthState(status: AuthStatus.restoring);
  }

  Future<void> login() {
    state = const AuthState(status: AuthStatus.authenticating);
    return _signIn(ref.read(authRepositoryProvider).login);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Signs the user in with [action], or leaves them signed out with an
  /// error. A cancelled login is not an error.
  Future<void> _signIn(Future<SpotifyUser?> Function() action) async {
    try {
      final user = await action();
      state = user == null
          ? const AuthState(status: AuthStatus.unauthenticated)
          : AuthState(status: AuthStatus.authenticated, user: user);
    } on AuthCancelledFailure {
      state = const AuthState(status: AuthStatus.unauthenticated);
    } on AppFailure catch (failure) {
      state = AuthState(status: AuthStatus.unauthenticated, failure: failure);
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        failure: AuthFailure(),
      );
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
