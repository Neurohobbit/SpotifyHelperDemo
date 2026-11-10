import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_helper/features/authentication/application/auth_controller.dart';
import 'package:spotify_helper/features/authentication/application/auth_state.dart';
import 'package:spotify_helper/features/authentication/presentation/auth_screen.dart';
import 'package:spotify_helper/features/playlist_generation/presentation/generate_playlist_screen.dart';

/// Shows the Spotify connect screen until the user is signed in.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(authControllerProvider).status) {
      AuthStatus.restoring => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthStatus.unauthenticated || AuthStatus.authenticating => const AuthScreen(),
      AuthStatus.authenticated => const GeneratePlaylistScreen(),
    };
  }
}
